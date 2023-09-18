require "rails_helper"

RSpec.describe SmokeTest, :smoke_test do
  subject(:use_case) { described_class.call(:one) }

  let(:expected_response) { File.read("./spec/fixtures/smoke_tests/use_case_one.json") }

  before { WebMock.disable! }

  after { WebMock.enable! }

  it "returns the expected output" do
    expect(use_case).to be true
    expect(Sidekiq.redis { |r| r.get("smoke-test-one") }).not_to be_nil
  end
end
