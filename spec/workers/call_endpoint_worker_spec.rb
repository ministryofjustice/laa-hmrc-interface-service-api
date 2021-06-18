require 'rails_helper'

RSpec.describe CallEndpointWorker do
  subject(:worker) { described_class.new }
  let(:task) { create :task }
  before do
    allow_any_instance_of(BearerToken).to receive(:call).and_return('new_fake_token_value')
    stub_request(:get, %r{\A#{Settings.credentials.host}/fake/.*\z}).to_return(status: 200, body: result)
  end
  let(:result) { valid_result }
  let(:valid_result) do
    '{"_links":{"individual":{"name":"GET","href":"/individuals/matching/8c4a59f1-e7c4-471e-95e7-f6cdc54286d1",' \
    '"title":"Get a matched individualxE2x80x99s information"},"self":{"href":"/individuals/matching/"}}}'
  end

  it { is_expected.to be_a CallEndpointWorker }

  describe '.perform' do
    subject(:perform) { worker.perform(task.id, test_url) }
    let(:test_url) { '/fake/url' }

    it 'updates the task.calls_completed' do
      expect { perform }.to change { task.reload.calls_started }.by(1)
    end

    context 'when the url contains benefits_and_credits' do
      let(:test_url) { '/fake/benefits-and-credits/url' }

      it 'parses the correct headers and still succeeds' do
        expect { perform }.to change { task.reload.calls_started }.by(1)
      end
    end

    context 'when the url contains {&fromDate,toDate}' do
      let(:test_url) { '/fake/benefits-and-credits/url{&fromDate,toDate}' }

      it 'parses the correct headers and still succeeds' do
        expect { perform }.to change { task.reload.calls_started }.by(1)
      end
    end

    context 'when the url contains {&fromTaxYear,toTaxYear}' do
      let(:test_url) { '/fake/benefits-and-credits/url{&fromTaxYear,toTaxYear}' }

      it 'parses the correct headers and still succeeds' do
        expect { perform }.to change { task.reload.calls_started }.by(1)
      end
    end
  end
end
