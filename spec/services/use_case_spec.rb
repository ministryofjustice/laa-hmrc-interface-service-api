require 'rails_helper'

RSpec.describe UseCase do
  subject(:use_case) { described_class.new(:one) }

  describe 'initializing' do
    context 'when a valid bearer_token is available' do
      before do
        REDIS.set('use_case_one_bearer_token', 'fake_token_value')
        subject
      end

      it 'does not call the bearer_token generator' do
        expect(BearerToken).not_to receive(:call)
      end
    end
  end
end
