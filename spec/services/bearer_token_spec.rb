require "rails_helper"

describe BearerToken do
  subject(:bearer_token) { described_class.new(use_case) }

  before do
    stub_request(:post, %r{\A#{Settings.credentials.hmrc_host}/oauth/token\z})
      .to_return(status: 200, body: fake_data)
  end

  let(:fake_data) do
    {
      access_token: "zz00000z00z0z00000z0z0z0000z0000",
      token_type: "bearer",
      # real response has other returns but out of scope of this test
    }.to_json
  end

  context "when called with an invalid use_case" do
    subject(:bearer_token) { described_class.new("not_a_use_case") }

    it { expect { bearer_token }.to raise_error "Unsupported UseCase" }
  end

  context "and UseCase one is passed" do
    let(:use_case) { "use_case_one" }

    describe "#call" do
      subject(:call) { bearer_token.call }

      it { is_expected.to eql "zz00000z00z0z00000z0z0z0000z0000" }
    end

    describe ".call" do
      subject(:call) { described_class.call("use_case_one") }

      it { is_expected.to eql "zz00000z00z0z00000z0z0z0000z0000" }
    end
  end

  context "and UseCase two is passed" do
    let(:use_case) { "use_case_two" }

    describe "#call" do
      subject(:call) { bearer_token.call }

      it { is_expected.to eql "zz00000z00z0z00000z0z0z0000z0000" }
    end
  end

  context "and UseCase three is passed" do
    let(:use_case) { "use_case_three" }

    describe "#call" do
      subject(:call) { bearer_token.call }

      it { is_expected.to eql "zz00000z00z0z00000z0z0z0000z0000" }
    end
  end

  context "and UseCase four is passed" do
    let(:use_case) { "use_case_four" }

    describe "#call" do
      subject(:call) { bearer_token.call }

      it { is_expected.to eql "zz00000z00z0z00000z0z0z0000z0000" }
    end
  end
end
