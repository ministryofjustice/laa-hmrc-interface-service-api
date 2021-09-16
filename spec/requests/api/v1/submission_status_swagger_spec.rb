require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'GET submission-status', type: :request, swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/submission-status/{id}' do
    get 'Retrieves the status of a submission' do
      tags 'submission-status'
      produces 'application/json'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'submission found' do
        let!(:submission) { create :submission, :in_progress }
        let(:id) { submission.id }
        let(:expected_response) do
          {
            submission: id,
            status: 'in_progress',
            _links: [
              href: "http://www.example.com/api/v1/submission-status/#{id}"
            ]
          }
        end
        run_test! do |response|
          expect(response.media_type).to eq('application/json')
          expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_response)
        end
      end

      response '404', 'submission not found' do
        let(:id) { '1234' }
        run_test!
      end
    end
  end
end
