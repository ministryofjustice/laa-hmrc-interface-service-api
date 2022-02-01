require 'rails_helper'

RSpec.describe UseCase do
  subject(:use_case) { described_class.new(:one) }

  describe 'initializing' do
    context 'when a valid bearer_token is available' do
      before do
        REDIS.set('use_case_one_bearer_token', 'fake_token_value')
        use_case
      end

      it 'does not call the bearer_token generator' do
        expect(BearerToken).not_to receive(:call)
      end
    end

    context 'when a valid bearer_token is not available' do
      before { allow(BearerToken).to receive(:call).with('use_case_one').and_return('new_fake_token_value') }

      it 'calls BearerToken and stores the value in redis' do
        expect(REDIS.get('use_case_one_bearer_token')).to be nil
        use_case
        expect(REDIS.get('use_case_one_bearer_token')).to eql 'new_fake_token_value'
      end
    end
  end

  describe '.host' do
    subject(:host) { use_case.host }

    before do
      REDIS.set('use_case_one_bearer_token', 'fake_token_value')
      host
    end

    it { is_expected.to eql Settings.credentials.use_case_one.host }
  end
end
