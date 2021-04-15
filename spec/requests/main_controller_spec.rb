require 'rails_helper'

describe MainController, type: :request do
  describe 'GET /main' do
    subject(:get_main) { get main_path }

    before { get_main }

    it 'returns success' do
      expect(response).to have_http_status(:success)
    end
  end
end
