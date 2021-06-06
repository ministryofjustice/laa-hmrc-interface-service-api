require 'rails_helper'

RSpec.describe UseCase do
  subject(:use_case) { described_class.new }

  describe 'initializing' do
    before { use_case }

    context 'when a valid bearer_token is available' do
      before { REDIS.set('use_case_1_bearer_token', 'fake_token_value') }

      it 'does not call the bearer_token generator' do
        expect(BearerToken).not_to receive(:call)
      end
    end
  end
end
