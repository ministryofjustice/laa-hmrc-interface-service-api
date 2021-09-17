require 'rails_helper'

RSpec.describe SubmissionProcessWorker do
  let(:worker) { described_class.new }
  let(:submission) { create :submission }

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
      expect(submission.status).to eq('processed')
    end

    context 'when the retry is exceeding the max retries' do
      before do
        worker.retry_count = 4
      end

      it 'sends a sentry alert' do
        expect(Sentry).to receive(:capture_message).with(/^Retry attempts exhausted for submission: #{submission.id}/)
        subject
      end

      it 'updates the submission status' do
        subject
        expect(submission.status).to eq('failed')
      end
    end
  end
end
