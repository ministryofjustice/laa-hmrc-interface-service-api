require "rails_helper"

describe MainController, type: :request do
  describe "GET /main" do
    subject(:get_main) { get main_path }

    before { get_main }

    it "redirects to the rswag documentation" do
      expect(response).to redirect_to("/api-docs")
    end
  end
end
