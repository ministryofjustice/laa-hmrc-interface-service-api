require 'rails_helper'

RSpec.describe TestWorker do
  subject(:worker) { described_class.new }

  it { is_expected.to be_a TestWorker }

  describe '.perform' do
    subject(:perform) { worker.perform(uuid) }
    let(:uuid) { 'fake-uid' }

    context 'when on the final retry' do
      before { worker.retry_count = 3 }
      let(:expected_message) do
        "Moving TestWorker# to dead set, it failed with: /An error occured\n"
      end

      it 'notifies sentry' do
        TestWorker.within_sidekiq_retries_exhausted_block do
          expect(Sentry).to receive(:capture_message).with(expected_message)
        end
      end

      it { expect { perform }.to raise_error ZeroDivisionError }
    end

    context 'when before the final retry' do
      before { worker.retry_count = 2 }

      it { expect { perform }.to raise_error TestWorker::SentryIgnoresThisSidekiqFailError }
    end
  end
end
