require 'swagger_helper'

RSpec.describe 'smoke_test', type: :request, swagger_doc: 'v1/swagger.yaml' do
  path '/smoke-test' do
    before do
      allow(REDIS).to receive(:get).with('smoke-test-one').and_return(true)
      allow(REDIS).to receive(:get).with('smoke-test-two').and_return(true)
      allow(REDIS).to receive(:get).with('smoke-test-three').and_return(true)
      allow(REDIS).to receive(:get).with('smoke-test-four').and_return(true)
    end

    get('call smoke_test') do
      description 'Fetch recent smoke_test results'
      response(200, 'Success') do
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
