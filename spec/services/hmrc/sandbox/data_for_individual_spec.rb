require "rails_helper"

RSpec.describe HMRC::Sandbox::DataForIndividual do
  subject(:instance) { described_class.new(individual:, use_case:, start_date:, end_date:)}

  let(:individual) { HMRC::Sandbox::Individual.new("Jim", "Bob", "1951-01-02", "XX123456X") }
  let(:use_case) { :one }
  let(:start_date) { '2022-10-01'.to_date }
  let(:end_date) { '2022-12-31'.to_date }

  describe "#retrieve" do
    subject(:retrieve) { instance.retrieve }

    let(:test_submission) { instance_double(TestSubmission) }

    before do
      allow(TestSubmission).to receive(:new).and_return(test_submission)
      allow(test_submission).to receive(:call).and_return("{\"some_key\":\"some_value\"}")
    end

    it "calls test TestSubmission" do
      retrieve
      expect(test_submission).to have_received(:call)
    end
  end

  describe "#append_paye" do
    subject(:append_paye) { instance.append_paye }

    before do
      allow(REDIS).to receive(:get).with("use_case_one_bearer_token").and_return("dummy_bearer_token")
      stub_request(:post, /\A#{Settings.credentials.host}.*\z/).to_return(status: 201, body: "", headers: {})
    end

    it "makes a single post to the expected endpoint" do
      append_paye

      expect(
        a_request(
          :post,
          /\Ahttps:\/\/fake.api\/individuals\/integration-framework-test-support\/individuals\/income\/paye\/nino\/XX123456X\?endDate=2022-12-31&startDate=2022-10-01&useCase=LAA-C1\z/
        )
      ).to have_been_made.times(1)
    end
  end

  describe "#append_employment" do
    subject(:append_employment) { instance.append_employment }

    before do
      allow(REDIS).to receive(:get).with("use_case_one_bearer_token").and_return("dummy_bearer_token")
      stub_request(:post, /\A#{Settings.credentials.host}.*\z/).to_return(status: 201, body: "", headers: {})
    end

    it "makes a single post to the expected endpoint" do
      append_employment

      expect(
        a_request(
          :post,
          /\Ahttps:\/\/fake.api\/individuals\/integration-framework-test-support\/individuals\/employment\/nino\/XX123456X\?endDate=2022-12-31&startDate=2022-10-01&useCase=LAA-C1\z/
        )
      ).to have_been_made.times(1)
    end
  end
end
