require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'GET submission', type: :request, swagger_doc: 'v1/swagger.yaml' do
  include AuthorisedRequestHelper

  let(:token) { application.access_tokens.create! }
  let(:Authorization) { "Bearer #{token.token}" }

  context 'create' do
    let(:application) { dk_application }
    let(:'filter[use_case]') { 'one' }
    let(:'filter[last_name]') { 'Yorke' }
    let(:'filter[first_name]') { 'Langley' }
    let(:'filter[nino]') { 'MN212451D' }
    let(:'filter[dob]') { '1992-07-22' }
    let(:'filter[start_date]') { '2020-08-01' }
    let(:'filter[end_date]') { '2020-10-01' }

    path '/api/v1/submission/create' do
      parameter name: 'filter[use_case]', in: :query, required: true, type: :string,
                description: 'Use case'

      parameter name: 'filter[first_name]', in: :query, required: true, type: :string,
                description: 'First name'

      parameter name: 'filter[last_name]', in: :query, required: true, type: :string,
                description: 'Last name'

      parameter name: 'filter[dob]', in: :query, required: true, type: :string,
                description: 'Date of birth'

      parameter name: 'filter[nino]', in: :query, required: true, type: :string,
                description: 'National Insurance Number'

      parameter name: 'filter[start_date]', in: :query, required: true, type: :string,
                description: 'Start date'

      parameter name: 'filter[end_date]', in: :query, required: true, type: :string,
                description: 'End date'

      post('Create new submission') do
        tags 'Submissions'
        produces 'application/json'
        consumes 'application/json'
        security [{ oAuth: [] }]
        response(202, 'Accepted') do
          description 'Create a submission record and start the HMRC process asyncronously'
          after do |example|
            example.metadata[:response][:content] = {
              'application/json' => {
                example: JSON.parse(response.body, symbolize_names: true)
              }
            }
          end
          run_test! do |response|
            expect(response.media_type).to eq('application/json')
            expect(response.body).to match(/id/)
            expect(response.body).to match(/_links/)
            expect(JSON.parse(response.body)['_links'].first['href']).to match(%r{http://www.example.com/api/v1/submission/status/})
          end
        end

        response(401, 'Error: Unauthorized') do
          let(:Authorization) { nil }

          run_test!
        end

        xcontext 'when data is bad' do
          response(400, 'Bad request') do
            let(:'filter[start_date]') { nil }
            let(:'filter[first_name]') { nil }
            let(:'filter[last_name]') { nil }
            let(:application) { dk_application(['use_case_three']) }

            run_test! do |response|
              expect(response.media_type).to eq('application/json')
              expect(response.body).to match(/Invalid use case/)
            end
          end
        end

        context 'when scope is invalid' do
          response(400, 'Bad request') do
            let(:'filter[use_case]') { 'three' }
            let(:application) { dk_application(%w[use_case_one use_case_two]) }

            run_test! do |response|
              expect(response.media_type).to eq('application/json')
              expect(response.body).to match(/Unauthorised use case/)
            end
          end
        end
      end
    end
  end

  context 'status' do
    let(:application) { dk_application }
    let!(:submission) { create :submission, :processing }
    let(:id) { submission.id }

    path '/api/v1/submission/status/{id}' do
      get 'Retrieves the status of a submission' do
        tags 'Submissions'
        produces 'application/json'
        consumes 'application/json'
        security [{ oAuth: [] }]
        parameter name: :id, in: :path, type: :string

        context 'when the submission has not completed' do
          response '202', 'incomplete submission found' do
            let(:expected_response) do
              {
                submission: id,
                status: 'processing',
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
        end

        context 'when the submission has completed' do
          let!(:submission) { create :submission, :completed, :with_attachment }
          response '200', 'complete submission found' do
            let(:expected_response) do
              {
                submission: id,
                status: 'completed',
                _links: [
                  href: "http://www.example.com/api/v1/submission/result/#{id}"
                ]
              }
            end
            run_test! do |response|
              expect(response.media_type).to eq('application/json')
              expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_response)
            end
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
        tags 'Submissions'
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
          let!(:submission) { create :submission, :processing }
          let(:expected_response) do
            {
              submission: id,
              status: 'processing',
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

        response 500, 'submission has been completed but no result object is present' do
          let!(:submission) { create :submission, :completed }
          let(:expected_response) do
            {
              code: 'INCOMPLETE_SUBMISSION',
              message: 'Process complete but no result available'
            }
          end
          run_test! do
            expect(response.media_type).to eq('application/json')
            expect(JSON.parse(response.body).symbolize_keys).to eq(expected_response)
          end
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
