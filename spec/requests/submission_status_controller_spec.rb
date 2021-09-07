require 'rails_helper'

RSpec.describe SubmissionStatusController, type: :request do
  describe 'GET /submission-status/:id' do
    let(:submission) { create :submission, :in_progress }
    before do
      get submission_status_id_path(id)
    end

    context 'with the submission id of an existent submission' do
      let(:id) { submission.id }
      let(:expected_response) do
        {
          submission: id,
          status: 'in_progress',
          _links: [
            href: "http://www.example.com/submission-status/#{id}"
          ]
        }
      end
      it 'returns success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the expected response' do
        expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_response)
      end
    end

    context 'with the submission id of a non-existent submission' do
      let(:id) { '1234' }
      it 'returns a 404 error' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
