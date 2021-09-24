require 'rails_helper'

RSpec.describe SubmissionProcessWorker do
  include AuthorisedRequestHelper

  let(:worker) { described_class.new }
  let(:application) { dk_application }
  let(:submission) { create :submission, oauth_application: application }

  subject { worker.perform(submission.id) }

  before do
    allow(Submission).to receive(:find).with(submission.id).and_return(submission)
    allow(SubmissionService).to receive(:call).and_return(true)
  end

  describe '.perform' do
    it 'calls SubmissionService' do
      expect(SubmissionService).to receive(:call)
      subject
    end

    it 'updates the submission status' do
      subject
      expect(submission.status).to eq('completed')
    end

    context 'when submission errors' do
      before do
        allow(SubmissionService).to receive(:call).and_raise(StandardError, 'A problem occurred')
      end

      context 'before the final retry' do
        before { worker.retry_count = 2 }

        it 'raises a not tracked error and leaves the status' do
          expect { subject }.to raise_error Errors::SentryIgnoresThisSidekiqFailError
          expect(submission.status).to eq 'processing'
        end
      end

      context 'when the retry is at the max retries' do
        let(:expected_message) { "Moving SubmissionProcessWorker# to dead set, it failed with: /An error occured\n" }

        before { worker.retry_count = 3 }

        it 'updates the submission status' do
          expect { subject }.to raise_error StandardError, 'A problem occurred'
          expect(submission.status).to eq('failed')
        end

        it 'notifies sentry of the deadset addition' do
          SubmissionProcessWorker.within_sidekiq_retries_exhausted_block do
            expect(Sentry).to receive(:capture_message).with(expected_message)
          end
        end
      end
    end
  end
end
