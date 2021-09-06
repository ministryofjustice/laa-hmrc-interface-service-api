# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Submission, type: :model, vcr: { cassette_name: 'use_case_one_success' } do
  subject(:submission) { described_class.create(params) }

  let(:params) do
    {
      use_case: 'one',
      first_name: 'Langley',
      last_name: 'Yorke',
      nino: 'MN212451D',
      dob: '1992-07-22',
      start_date: '2020-08-01',
      end_date: '2020-10-01'
    }
  end

  it {
    is_expected.to validate_inclusion_of(:use_case).in_array(%w[one two three four]).with_message(/Invalid use case/)
  }

  describe '.as_json' do
    subject(:as_json) { submission.as_json }

    it 'returns the expected values' do
      expect(as_json.keys).to match_array %w[use_case first_name last_name nino dob start_date end_date]
    end

    it 'does not include standard model values' do
      expect(as_json.keys).to_not include %w[id status created_at updated_at]
    end
  end

  describe '#process!' do
    subject(:process!) { submission.process! }

    before do
      remove_request_stub(@hmrc_stub_requests)
      allow(REDIS).to receive(:get).with('use_case_one_bearer_token').and_return('dummy_bearer_token')
    end

    it 'adds a result attachment to the submission' do
      expect do
        subject
      end.to change(ActiveStorage::Attachment, :count).by(1)
    end

    it 'gives the result attachment the a filename' do
      subject
      expect(submission.result.filename).to eq "#{submission.id}.json"
    end

    it 'gives the result attachment a key' do
      subject
      expect(submission.result.key).to eq "submission/result/#{submission.id}"
    end

    it 'gives the result attachment a content type' do
      subject
      expect(submission.result.content_type).to eq 'application/json'
    end

    context 'RestClient::InternalServerError' do
      before do
        allow(RestClient).to receive(:get).with(any_args).and_raise(RestClient::InternalServerError)
      end

      it 'adds a result attachment detailing the error' do
        subject
        expect(submission.result.blob.download).to match(/returned INTERNAL_SERVER_ERROR/)
      end
    end
  end
end
