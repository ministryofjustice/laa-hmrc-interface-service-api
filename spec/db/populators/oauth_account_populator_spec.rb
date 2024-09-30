require "rails_helper"
require Rails.root.join("db/populators/oauth_account_populator")

RSpec.describe OauthAccountPopulator do
  describe ".call" do
    subject(:call) { described_class.call }

    before do
      allow(ENV).to receive(:fetch).with("TEST_OAUTH_ACCOUNTS_JSON", nil) { json_string_from_secret }
    end

    let(:json_string_from_secret) { "[{\"name\":\"name-one\",\"scopes\":[\"use_case_one\",\"use_case_two\"],\"uid\":\"uuid-001\",\"secret\":\"secret-001\"},{\"name\":\"name-two\",\"scopes\":[\"use_case_three\"],\"uid\":\"uuid-002\",\"secret\":\"secret-002\"}]" }

    it "seeds the test oauth accounts from secrets" do
      expect { call }.to change(Doorkeeper::Application, :count).from(0).to(2)
    end

    it "seeds the expected test oauth accounts" do
      call

      expect(Doorkeeper::Application.all).to contain_exactly(
        have_attributes(name: "name-one", scopes: %w[use_case_one use_case_two], uid: "uuid-001", secret: "secret-001"),
        have_attributes(name: "name-two", scopes: %w[use_case_three], uid: "uuid-002", secret: "secret-002"),
      )
    end
  end
end
