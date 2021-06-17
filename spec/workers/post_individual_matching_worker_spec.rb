require 'rails_helper'

RSpec.describe PostIndividualMatchingWorker do
  subject(:worker) { described_class.new }
  let(:task) { create :task }
  it { is_expected.to be_a PostIndividualMatchingWorker }
  before do
    allow_any_instance_of(BearerToken).to receive(:call).and_return('new_fake_token_value')
    stub_request(:post, %r{\A#{Settings.credentials.host}/individuals/matching\z}).to_return(status: 200, body: result)
  end
  let(:result) { valid_result }
  let(:valid_result) do
    '{"_links":{"individual":{"name":"GET","href":"/individuals/matching/8c4a59f1-e7c4-471e-95e7-f6cdc54286d1",' \
    '"title":"Get a matched individualxE2x80x99s information"},"self":{"href":"/individuals/matching/"}}}'
  end

  describe '.perform' do
    subject(:perform) { worker.perform(task.id) }

    it 'requests data from the correct endpoint' do
      perform
      expect(a_request(:post, "#{Settings.credentials.host}/individuals/matching")).to have_been_made.times(1)
    end

    it 'updates the task.calls_completed' do
      expect { perform }.to change { task.reload.calls_completed }.by(1)
    end
  end
end
