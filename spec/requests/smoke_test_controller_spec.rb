require 'rails_helper'

RSpec.describe SmokeTestController, type: :request do
  subject(:get_smoke_test) { get smoke_test_path }
  before do
    allow_any_instance_of(SmokeTest).to receive(:call).and_return(smoke_test_pass?)
    subject
  end
  let(:expected_result) { { smoke_test_result: smoke_test_pass? }.to_json }

  describe '#call' do
    context 'when the smoke test passes' do
      let(:smoke_test_pass?) { true }
      it { expect(response.body).to eql expected_result }
      it { expect(response.status).to eql 200 }
    end

    context 'when the smoke test failes' do
      let(:smoke_test_pass?) { false }
      it { expect(response.body).to eql expected_result }
      it { expect(response.status).to eql 500 }
    end
  end
end
