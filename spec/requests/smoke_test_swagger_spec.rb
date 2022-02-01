require "swagger_helper"

RSpec.describe "smoke_test", type: :request, swagger_doc: "v1/swagger.yaml" do
  let(:use_case) { "one" }

  path "/smoke-test/{use_case}" do
    let(:smoke_test) { instance_double(SmokeTest) }
    let(:success) { true }

    before do
      allow(SmokeTest).to receive(:new).and_return(smoke_test)
      allow(smoke_test).to receive(:call).and_return(success)
    end

    get("individual use_case smoke-test") do
      description "Run a smoke test for chosen use_case"
      tags "Smoke tests"
      consumes "application/json"
      produces "application/json"
      parameter name: :use_case, in: :path, type: :string
      response(200, "success") do
        examples "application/json" => {
          smoke_test_one_result: true,
        }
        run_test!
      end
      response(500, "internal server error") do
        let(:success) { false }

        examples "application/json" => {
          smoke_test_one_result: false,
        }
        run_test!
      end
    end
  end

  path "/smoke-test" do
    before do
      allow(REDIS).to receive(:get).with("smoke-test-one").and_return(test_one_result)
      allow(REDIS).to receive(:get).with("smoke-test-two").and_return(true)
      allow(REDIS).to receive(:get).with("smoke-test-three").and_return(true)
      allow(REDIS).to receive(:get).with("smoke-test-four").and_return(true)
    end

    let(:test_one_result) { true }

    get("call smoke_test") do
      description "Fetch smoke_test results that have been generated within the last hour"
      tags "Smoke tests"
      consumes "application/json"
      produces "application/json"
      response(200, "success") do
        examples "application/json" => {
          smoke_test_result:
            {
              use_case_one: true,
              use_case_two: true,
              use_case_three: true,
              use_case_four: true,
            },
        }
        run_test!
      end

      response(500, "internal server error") do
        let(:test_one_result) { false }
        examples "application/json" => {
          smoke_test_result:
            {
              use_case_one: false,
              use_case_two: true,
              use_case_three: true,
              use_case_four: true,
            },
        }
        run_test!
      end
    end
  end
end
