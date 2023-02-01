require "rails_helper"

RSpec.describe HMRC::Sandbox::TestDataCreator do
  subject(:instance) { described_class.new(nino:, use_case:) }

  let(:nino) { 'JA123456D'}
  let(:use_case) { :one }
  let(:start_date) { '2022-10-01'.to_date }
  let(:end_date) { '2022-12-31'.to_date }

  before do
    remove_request_stub(hmrc_stub_requests)
    allow(REDIS).to receive(:get).with("use_case_one_bearer_token").and_return("dummy_bearer_token")
    stub_request(:post, /\A#{Settings.credentials.host}.*\z/).to_return(status: 201, body: "", headers: {})
  end

  context "when called on production" do
    before { allow(Settings).to receive(:environment).and_return("production") }

    it { expect { instance }.to raise_error HMRC::Sandbox::ProductionError }
  end

  context "when the use is invalid" do
    let(:use_case) { :five }

    it { expect { instance }.to raise_error HMRC::Sandbox::UseCaseError }
  end

  describe "#create!" do
    subject(:create) { instance.create!(endpoint:, start_date:, end_date:) }

    context "when creating income/paye" do
      let(:endpoint) { :paye }

      it "makes a single post to the expected endpoint" do
        create

        expect(
          a_request(
            :post,
            /\Ahttps:\/\/fake.api\/individuals\/integration-framework-test-support\/individuals\/income\/paye\/nino\/JA123456D\?endDate=2022-12-31&startDate=2022-10-01&useCase=LAA-C1\z/
          )
        ).to have_been_made.times(1)
      end
    end

    context "when creating employments" do
      let(:endpoint) { :employment }

      it "makes a single post to the expected endpoint" do
        create

        expect(
          a_request(
            :post,
            /\Ahttps:\/\/fake.api\/individuals\/integration-framework-test-support\/individuals\/employment\/nino\/JA123456D\?endDate=2022-12-31&startDate=2022-10-01&useCase=LAA-C1\z/
          )
        ).to have_been_made.times(1)
      end
    end

    context "when the endpoint is invalid" do
      let(:endpoint) { :tax_credit }

      it { expect { create }.to raise_error HMRC::Sandbox::EndpointError }
    end
  end
end
