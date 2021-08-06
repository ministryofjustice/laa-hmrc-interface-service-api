require 'rails_helper'

RSpec.describe SmokeTestController, type: :request do
  describe '#use-case' do
    before do
      allow_any_instance_of(SmokeTest).to receive(:call).and_return(true)
      subject
    end

    subject(:get_smoke_test) { get smoke_test_use_case_path('one') }
    let(:expected_result) { '{"smoke_test_one_result":true}' }

    it { expect(response.body).to eql expected_result }
    it { expect(response.status).to eql 200 }
  end

  describe '#healthcheck' do
    subject(:get_smoke_test) { get smoke_test_path }

    before do
      allow(REDIS).to receive(:get).with('smoke-test-one').and_return(test_one_result)
      allow(REDIS).to receive(:get).with('smoke-test-two').and_return(true)
      allow(REDIS).to receive(:get).with('smoke-test-three').and_return(true)
      allow(REDIS).to receive(:get).with('smoke-test-four').and_return(true)
      subject
    end
    let(:expected_result) do
      {
        smoke_test_result:
          {
            use_case_one: test_one_result,
            use_case_two: true,
            use_case_three: true,
            use_case_four: true
          }
      }.to_json
    end

    context 'when all smoke tests pass' do
      let(:test_one_result) { true }

      it { expect(response.body).to eql expected_result }
      it { expect(response.status).to eql 200 }
    end

    context 'when a smoke test fails' do
      let(:test_one_result) { false }

      it { expect(response.body).to eql expected_result }
      it { expect(response.status).to eql 500 }
    end

    context 'when a smoke test has not run' do
      let(:test_one_result) { nil }

      it { expect(response.body).to eql expected_result }
      it { expect(response.status).to eql 500 }
    end
  end
end
