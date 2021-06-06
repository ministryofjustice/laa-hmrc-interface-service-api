require 'rails_helper'

RSpec.describe UseCase do
  subject(:use_case) { described_class.new }

  it { is_expected.to be_a UseCase }

  context 'when a valid bearer_token is available' do
    # set up mock-redis with a value

    it 'does not call the bearer_token generator' do
      expect(BearerToken).not_to receive(:call)
    end
  end
end
