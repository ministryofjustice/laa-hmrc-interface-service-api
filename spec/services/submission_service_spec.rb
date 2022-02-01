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
        oauth_application: application
      }
    end

    before do
      remove_request_stub(@hmrc_stub_requests)
      allow(REDIS).to receive(:get).with('use_case_one_bearer_token').and_return('dummy_bearer_token')
    end

    it 'adds a result attachment to the submission' do
      expect { call }.to change(ActiveStorage::Attachment, :count).by(1)
    end

    it 'gives the submission result attachment the a filename' do
      call
      expect(submission.result.filename).to eq "#{submission.id}.json"
    end

    it 'gives the submission result attachment a key' do
      call
      expect(submission.result.key).to eq "submission/result/#{submission.id}"
    end

    it 'gives the submission result attachment a content type' do
      call
      expect(submission.result.content_type).to eq 'application/json'
    end

    context 'when the details are complete but not found on the calling service',
            vcr: { cassette_name: 'use_case_one_fail' } do
      let(:data) do
        {
          use_case: 'one',
          first_name: 'this user',
          last_name: 'does-not-exist',
          nino: 'MN212451D',
          dob: '1992-07-22',
          start_date: '2020-08-01',
          end_date: '2020-10-01',
          oauth_application: application
        }
      end

      it 'raises an error and records the error in the result' do
        expect { call }.to raise_error Errors::CitizenDetailsMismatchError, 'User details not matched'
        expect(submission.result.blob.download).to match(/submitted client details could not be found in HMRC service/)
      end
    end

    context 'when the call fails with RestClient::InternalServerError' do
      before do
        allow(RestClient).to receive(:get).with(any_args).and_raise(RestClient::InternalServerError)
      end

      it 'adds a result attachment detailing the error' do
        call
        expect(submission.result.blob.download).to match(/returned INTERNAL_SERVER_ERROR/)
      end
    end

    context 'when the call fails with RestClient::TooManyRequests' do
      before do
        call_count = 0
        allow(RestClient).to receive(:get).with(any_args) do
          if call_count < 1
            call_count += 1
            raise(RestClient::TooManyRequests)
          else
            { _links: {} }.to_json
          end
        end
      end

      it 'logs that rate limiting occurred' do
        allow(Rails.logger).to receive(:info).at_least(:once)
        call
        expect(Rails.logger).to have_received(:info).with(/Rate limited while calling/).once
      end

      it 'adds a result attachment to the submission' do
        expect { call }.to change(ActiveStorage::Attachment, :count).by(1)
      end

      it 'does not add a result attachment detailing an error' do
        call
        expect(submission.result.blob.download).not_to match(/ERROR/)
      end
    end
  end
end
