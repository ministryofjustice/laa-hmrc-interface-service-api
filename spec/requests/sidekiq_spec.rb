require "rails_helper"

RSpec.describe "sidekiq WEB UI" do
  describe "GET /sidekiq" do
    it "returns unauthorized status" do
      get sidekiq_web_path

      expect(response).to have_http_status(:unauthorized)
    end

    context "with the right authentication" do
      it "is successful" do
        username = Settings.sidekiq.username
        password = Settings.sidekiq.web_ui_password
        get sidekiq_web_path, headers: {
          "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(username, password),
        }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
