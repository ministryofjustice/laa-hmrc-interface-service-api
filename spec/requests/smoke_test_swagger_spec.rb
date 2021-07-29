require 'swagger_helper'

RSpec.describe 'smoke_test', type: :request, swagger_doc: "v1/swagger.yaml" do

  path '/smoke-test' do
    before do
      allow_any_instance_of(SmokeTest).to receive(:call).and_return(true)
    end

    get('call smoke_test') do
      response(200, 'true') do

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
