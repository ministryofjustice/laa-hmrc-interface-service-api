require 'rails_helper'

describe BearerToken do
  subject(:bearer_token) { described_class.new }

  let(:faked_response) do
    {
      access_token: 'zz00000z00z0z00000z0z0z0000z0000',
      token_type: 'bearer'
      # real response has other returns but out of scope of this test
    }.to_json
  end

  before do
    stub_request(:post, %r{\A#{Settings.credentials.apply.host}/oauth/token\z}).to_return(status: 200, body: faked_response)
  end

  describe '.call' do
    subject(:call) { bearer_token.call }

    it { is_expected.to eql 'zz00000z00z0z00000z0z0z0000z0000' }
  end

  describe '.call' do
    subject(:call) { described_class.call }
    it { is_expected.to eql 'zz00000z00z0z00000z0z0z0000z0000' }
  end
end
