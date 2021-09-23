require 'rails_helper'

RSpec.describe SubmissionService, vcr: { cassette_name: 'use_case_one_success' } do
  include AuthorisedRequestHelper

  describe '.call' do
    subject(:call) { described_class.call(submission) }
    let(:submission) { create :submission, data }
    let(:application) { dk_application }
    let(:data) do
      {
        use_case: 'one',
        first_name: 'Langley',
        last_name: 'Yorke',
        nino: 'MN212451D',
        dob: '1992-07-22',
        start_date: '2020-08-01',
        end_date: '2020-10-01',
        oauth_application_id: application.id
      }
    end

    before do
      remove_request_stub(@hmrc_stub_requests)
      allow(REDIS).to receive(:get).with('use_case_one_bearer_token').and_return('dummy_bearer_token')
    end

    it 'adds a result attachment to the submission' do
      expect do
        subject
      end.to change(ActiveStorage::Attachment, :count).by(1)
    end

    it 'gives the submission result attachment the a filename' do
      subject
      expect(submission.result.filename).to eq "#{submission.id}.json"
    end

    it 'gives the submission result attachment a key' do
      subject
      expect(submission.result.key).to eq "submission/result/#{submission.id}"
    end

    it 'gives the submission result attachment a content type' do
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
