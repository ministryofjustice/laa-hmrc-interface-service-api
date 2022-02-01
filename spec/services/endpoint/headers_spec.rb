require "rails_helper"

RSpec.describe Endpoint::Headers do
  subject(:headers) { described_class.new(href, correlation_id, token) }

  let(:correlation_id) { "fake-correlation_id" }
  let(:token) { "fake_bearer_token" }

  describe "#call" do
    subject(:call) { described_class.call(href, correlation_id, token) }

    context "when there is no matchID" do
      let(:href) { "individuals/matching" }
      let(:expected_hash) do
        {
          accept: "application/vnd.hmrc.2.0+json",
          content_type: "application/json",
          correlationId: "fake-correlation_id",
          Authorization: "Bearer fake_bearer_token",
        }
      end

      it { is_expected.to eql expected_hash }
    end
  end

  describe ".call" do
    subject(:call) { headers.call }

    context "when there is no matchID" do
      let(:href) { "individuals/matching" }
      let(:expected_hash) do
        {
          accept: "application/vnd.hmrc.2.0+json",
          content_type: "application/json",
          correlationId: "fake-correlation_id",
          Authorization: "Bearer fake_bearer_token",
        }
      end

      it { is_expected.to eql expected_hash }
    end

    context "when the url end with individuals/matching but has a uuid" do
      let(:href) { "individuals/matching/fake-uuid" }
      let(:expected_hash) do
        {
          accept: "application/vnd.hmrc.2.0+json",
          correlationId: "fake-correlation_id",
          Authorization: "Bearer fake_bearer_token",
        }
      end

      it { is_expected.to eql expected_hash }
    end

    context "when the url includes benefits-and-credits" do
      let(:href) { "/root/benefits-and-credits/sub?matchId=fake-uuid" }
      let(:expected_hash) do
        {
          accept: "application/vnd.hmrc.1.0+json",
          correlationId: "fake-correlation_id",
          Authorization: "Bearer fake_bearer_token",
        }
      end

      it { is_expected.to eql expected_hash }
    end

    context "when the url does not include benefits-and-credits" do
      let(:href) { "/root/employment?matchId=fake-uuid" }
      let(:expected_hash) do
        {
          accept: "application/vnd.hmrc.2.0+json",
          correlationId: "fake-correlation_id",
          Authorization: "Bearer fake_bearer_token",
        }
      end

      it { is_expected.to eql expected_hash }
    end
  end
end
