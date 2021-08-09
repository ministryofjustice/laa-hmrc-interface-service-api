require 'rails_helper'

RSpec.describe Api::V1::UseCaseController, type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:'filter[first_name]') { 'first' }
  let(:'filter[last_name]') { 'last' }
  let(:'filter[date_of_birth]') { '1992-01-01' }
  let(:'filter[nino]') { 'QQ123456A' }
  let(:'filter[start_date]') { '2021-01-01' }
  let(:'filter[end_date]') { '2021-03-31' }

  before { allow(ApplyGetTest).to receive(:call).and_return({ success: 'true' }) }

  path '/api/v1/use_case' do
    get('get hearing') do
      description 'GET individual user data for use_case one'
      consumes 'application/json'
      tags 'Apply service'
      security [{ oAuth: [] }]

      parameter name: 'filter[first_name]', in: :query, required: true, type: :string,
                # schema: {
                #   '$ref': 'hearing.json#/definitions/id',
                # },
                description: 'The first name of the individual'

      parameter name: 'filter[last_name]', in: :query, required: true, type: :string,
                description: 'The last name of the individual'

      parameter name: 'filter[date_of_birth]', in: :query, required: true, type: :string,
                description: "The individual's date of birth (YYYY-MM-DD)"

      parameter name: 'filter[nino]', in: :query, required: true, type: :string,
                description: "The individual's National Insurance number"

      parameter name: 'filter[start_date]', in: :query, required: true, type: :string,
                description: 'The earliest date you need data from'

      parameter name: 'filter[end_date]', in: :query, required: true, type: :string,
                description: 'The end date you need data to'

      context 'with success' do
        let(:Authorization) { "Bearer #{token.token}" }

        response(200, 'Success') do
          run_test!
        end
      end

      context 'when request is unauthorized' do
        response('401', 'Unauthorized') do
          let(:Authorization) { nil }

          run_test!
        end
      end
    end
  end
end
