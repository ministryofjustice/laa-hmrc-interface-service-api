require 'rails_helper'

describe HMRC::Sandbox::CreateTestData do
  subject(:create_data) { described_class.new(type) }

  let(:type) { :paye }
  before do
    remove_request_stub(@hmrc_stub_requests)
    allow(REDIS).to receive(:get).with('use_case_one_bearer_token').and_return('dummy_bearer_token')
    stub_request(:post, /\A#{Settings.credentials.host}.*\z/).to_return(status: 201, body: '', headers: {})
  end

  describe '.call' do
    subject(:call) { create_data.call }

    it 'makes a single post to the expected endpoint' do
      call
      expect(a_request(:post, /\A#{Settings.credentials.host}.*#{type}.*\z/)).to have_been_made.times(1)
    end
  end

  describe '#call' do
    subject(:call) { described_class.call(type, '2021-01-01', '2021-02-01') }
    let(:type) { :employment }

    it 'makes a single post to the expected endpoint' do
      call
      expect(a_request(:post, /\A#{Settings.credentials.host}.*#{type}.*\z/)).to have_been_made.times(1)
    end
  end
  context 'when called on production' do
    before { allow(Settings).to receive(:environment).and_return('production') }

    it { expect { subject }.to raise_error HMRC::Sandbox::ProductionError }
  end

  context 'when the type is invalid' do
    let(:type) { :tax_credit }

    it { expect { subject }.to raise_error HMRC::Sandbox::TypeError }
  end
end
