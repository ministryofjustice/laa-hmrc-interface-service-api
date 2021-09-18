require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'GET submission', type: :request, swagger_doc: 'v1/swagger.yaml' do
  include AuthorisedRequestHelper

  let(:token) { application.access_tokens.create! }
  let(:Authorization) { "Bearer #{token.token}" }

  context 'status' do
    let(:application) { dk_application }
    let!(:submission) { create :submission, :in_progress }
    let(:id) { submission.id }

    path '/api/v1/submission/status/{id}' do
      get 'Retrieves the status of a submission' do
        tags 'submission-status'
        produces 'application/json'
        consumes 'application/json'
        security [{ oAuth: [] }]
        parameter name: :id, in: :path, type: :string

        response '200', 'submission found' do
          let(:expected_response) do
            {
              submission: id,
              status: 'in_progress',
              _links: [
                href: "http://www.example.com/api/v1/submission/status/#{id}"
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

        response(401, 'Error: Unauthorized') do
          let(:Authorization) { nil }

          run_test!
        end
      end
    end
  end

  context 'result' do
    let(:application) { dk_application }
    let(:id) { submission.id }

    path '/api/v1/submission/result/{id}' do
      get 'Retrieves a submission' do
        tags 'submission'
        produces 'application/json'
        consumes 'application/json'
        security [{ oAuth: [] }]
        parameter name: :id, in: :path, type: :string

        response 200, 'completed submission found' do
          let!(:submission) { create :submission, :completed, :with_attachment }
          let(:expected_response) { { data: 'test_data' } }
          run_test! do |response|
            expect(response.media_type).to eq('application/json')
            expect(JSON.parse(response.body).symbolize_keys).to eq(expected_response)
          end
        end

        response 202, 'incomplete submission found' do
          let!(:submission) { create :submission, :in_progress }
          run_test!
        end

        response 500, 'submission has been completed but no result object is present' do
          let!(:submission) { create :submission, :completed }
          run_test!
        end

        response 404, 'submission not found' do
          let(:id) { '1234' }
          run_test!
        end

        response 401, 'Error: Unauthorized' do
          let(:id) { '1234' }
          let(:Authorization) { nil }
          run_test!
        end
      end
    end
  end
end
