require 'swagger_helper'

RSpec.describe 'api/v1/use_case', type: :request, swagger_doc: 'v1/swagger.yaml' do
  let(:'filter[use_case]') { 'one' }
  let(:'filter[last_name]') { 'Yorke' }
  let(:'filter[first_name]') { 'Langley' }
  let(:'filter[nino]') { 'MN212451D' }
  let(:'filter[dob]') { '1992-07-22' }
  let(:'filter[start_date]') { '2020-08-01' }
  let(:'filter[end_date]') { '2020-10-01' }

  path '/api/v1/use_case/submit' do
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

    post('call use_case/submit') do
      tags 'Use cases'
      produces 'application/json'
      consumes 'application/json'
      response(202, 'Accepted') do
        description 'Post a submission to HMRC'
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
          expect(JSON.parse(response.body)['_links'].first['href']).to match(%r{http://www.example.com/api/v1/submission-status/})
        end
      end

      context 'when data is bad' do
        response(400, 'Bad request') do
          let(:'filter[use_case]') { 'five' }

          run_test! do |response|
            expect(response.media_type).to eq('application/json')
            expect(response.body).to match(/Invalid use case/)
          end
        end
      end
    end
  end

  path '/api/v1/use_case/one' do
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

    before do
      remove_request_stub(@hmrc_stub_requests)
      allow(REDIS).to receive(:get).with('use_case_one_bearer_token').and_return('dummy_bearer_token')
    end

    get('call use_case/one') do
      tags 'Use cases'
      produces 'application/json'
      consumes 'application/json'
      response(200, 'Success') do
        around do |example|
          VCR.use_cassette('use_case_one_success') do
            example.run
          end
        end

        description 'Fetch use case one results'

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/use_case/two' do
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

    before do
      remove_request_stub(@hmrc_stub_requests)
      allow(REDIS).to receive(:get).with('use_case_two_bearer_token').and_return('dummy_bearer_token')
    end

    get('call use_case/two') do
      tags 'Use cases'
      produces 'application/json'
      consumes 'application/json'
      response(200, 'Success') do
        around do |example|
          VCR.use_cassette('use_case_two_success') do
            example.run
          end
        end

        description 'Fetch use case two results'

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/use_case/three' do
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

    before do
      remove_request_stub(@hmrc_stub_requests)
      allow(REDIS).to receive(:get).with('use_case_three_bearer_token').and_return('dummy_bearer_token')
    end

    get('call use_case/three') do
      tags 'Use cases'
      produces 'application/json'
      consumes 'application/json'
      response(200, 'Success') do
        around do |example|
          VCR.use_cassette('use_case_three_success') do
            example.run
          end
        end

        description 'Fetch use case three results'

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/use_case/four' do
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

    before do
      remove_request_stub(@hmrc_stub_requests)
      allow(REDIS).to receive(:get).with('use_case_four_bearer_token').and_return('dummy_bearer_token')
    end

    get('call use_case/four') do
      tags 'Use cases'
      produces 'application/json'
      consumes 'application/json'
      response(200, 'Success') do
        around do |example|
          VCR.use_cassette('use_case_four_success') do
            example.run
          end
        end

        description 'Fetch use case four results'

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end
end
