require "rails_helper"
require "swagger_helper"

RSpec.shared_examples "GET submission" do
  describe "GET submission", type: :request do
    include AuthorisedRequestHelper

    let(:token) { application.access_tokens.create! }
    let(:Authorization) { "Bearer #{token.token}" }

    context "when create is called" do
      let(:application) { dk_application }
      let(:use_case) { "one" }
      let(:submission) do
        {
          filter: {
            use_case: "one",
            last_name: "Yorke",
            first_name: "Langley",
            nino: "MN212451D",
            dob: "1992-07-22",
            start_date: "2020-08-01",
            end_date: "2020-10-01",
          },
        }
      end

      path "/api/v1/submission/create/{use_case}" do
        post("Create new submission") do
          tags "Submissions"
          produces "application/json"
          consumes "application/json"
          security [{ oAuth: [] }]
          parameter name: :use_case,
                    in: :path,
                    required: true,
                    type: :string,
                    description: "The use case you wish to request",
                    schema: { enum: %w[one two three four] }
          parameter name: :submission,
                    in: :body,
                    required: true,
                    schema: {
                      type: :object,
                      properties: {
                        filter: {
                          type: :object,
                          properties: {
                            first_name: { type: String, example: "Langley" },
                            last_name: { type: String, example: "Yorke" },
                            nino: { type: String, example: "MN212451D" },
                            dob: { type: Date, example: "1992-07-22" },
                            start_date: { type: Date, example: "2020-08-01" },
                            end_date: { type: Date, example: "2020-10-01" },
                          },
                        },
                      },
                    }
          response(202, "Accepted") do
            description "Create a submission record and start the HMRC process asynchronously"
            after do |example|
              example.metadata[:response][:content] = {
                "application/json" => {
                  example: JSON.parse(response.body, symbolize_names: true),
                },
              }
            end

            run_test! do |response|
              expect(response.media_type).to eq("application/json")
              expect(response.body).to match(/id/)
              expect(response.body).to match(/_links/)
              json_response = JSON.parse(response.body)

              expect(json_response["_links"].first["href"]).to eq "http://www.example.com/api/v1/submission/result/#{json_response['id']}"
            end
          end

          response(401, "Error: Unauthorized") do
            let(:Authorization) { nil }

            run_test!
          end

          context "when use_case is bad" do
            response(400, "Bad request") do
              let(:application) { dk_application(%w[use_case_three]) }

              run_test! do |response|
                expect(response.media_type).to eq("application/json")
                expect(response.body).to match(/Unauthorised use case/)
              end
            end
          end

          context "when data is bad" do
            response(400, "Bad request") do
              let(:submission) do
                {
                  filter: {
                    last_name: nil,
                    first_name: nil,
                    nino: "abc123",
                    dob: "1234",
                    start_date: nil,
                    end_date: nil,
                  },
                }
              end
              run_test! do |response|
                errors = JSON.parse(response.body)
                expect(response.media_type).to eq("application/json")
                expect(errors["first_name"]).to eq(["can't be blank"])
                expect(errors["last_name"]).to eq(["can't be blank"])
                expect(errors["nino"]).to eq(["is not valid"])
                expect(errors["dob"]).to eq(["is not a valid date"])
                expect(errors["start_date"]).to eq(["is not a valid date"])
                expect(errors["end_date"]).to eq(["is not a valid date"])
              end
            end
          end

          context "when scope is invalid" do
            response(400, "Bad request") do
              let(:use_case) { "three" }
              let(:application) { dk_application(%w[use_case_one use_case_two]) }

              run_test! do |response|
                expect(response.media_type).to eq("application/json")
                expect(response.body).to match(/Unauthorised use case/)
              end
            end
          end
        end
      end
    end

    context "when result is called" do
      let(:application) { dk_application }
      let(:id) { submission.id }

      path "/api/v1/submission/result/{id}" do
        get "Retrieves a submission" do
          tags "Submissions"
          produces "application/json"
          consumes "application/json"
          security [{ oAuth: [] }]
          parameter name: :id, in: :path, type: :string

          response 200, "Submission completed or failed" do
            context "when completed with attachment" do
              let(:submission) { create :submission, :completed, :with_attachment, oauth_application: application }

              let(:expected_response) do
                {
                  submission: "test-guid",
                  status: "completed",
                  data: [
                    { correlation_id: "test-guid", use_case: "use_case_two" },
                    { test_key: "test value" },
                  ],
                }
              end

              run_test! do |response|
                expect(response.media_type).to eq("application/json")
                expect(JSON.parse(response.body).deep_symbolize_keys).to eq(expected_response)
              end
            end

            context "when failed with attachment" do
              let(:submission) { create :submission, :failed_with_attachment, oauth_application: application }

              let(:expected_response) do
                {
                  submission: "test-guid",
                  status: "failed",
                  data: [
                    { correlation_id: "test-guid", use_case: "use_case_two" },
                    { error: "submitted client details could not be found in HMRC service" },
                  ],
                }
              end

              run_test! do |response|
                expect(response.media_type).to eq("application/json")
                expect(JSON.parse(response.body).deep_symbolize_keys).to eq(expected_response)
              end
            end
          end

          response 202, "Submission still processing" do
            let!(:submission) { create :submission, :processing, oauth_application: application }
            let(:expected_response) do
              {
                submission: id,
                status: "processing",
                _links: [href: "http://www.example.com/api/v1/submission/status/#{id}"],
              }
            end
            run_test! do |response|
              expect(response.media_type).to eq("application/json")
              expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_response)
            end
          end

          response 500, "Submission complete but no result object is present" do
            let!(:submission) { create :submission, :completed, oauth_application: application }
            let(:expected_response) do
              {
                submission: id,
                status: "completed",
                code: "INCOMPLETE_SUBMISSION",
                message: "Process complete but no result available",
              }
            end
            run_test! do
              expect(response.media_type).to eq("application/json")
              expect(JSON.parse(response.body).symbolize_keys).to eq(expected_response)
            end
          end

          response 404, "Submission not found" do
            let(:id) { "1234" }
            run_test!
          end

          response 401, "Error: Unauthorized" do
            let(:id) { "1234" }
            let(:Authorization) { nil }
            run_test!
          end

          context "when application is not the application that created the submission" do
            response(400, "Bad request") do
              let(:submitting_application) { dk_application }
              let(:submission) do
                create :submission, :processing, oauth_application: submitting_application
              end

              run_test! do |response|
                expect(response.media_type).to eq("application/json")
                expect(response.body).to match(/Unauthorised application/)
              end
            end
          end
        end
      end
    end
  end
end

# This generates submissions endpoints for swagger in two sets of swagger
# docs because production environment only shows the "v1/live/swagger.yaml"
# version, staging and UAT shows the "v1/swagger.yaml" version
#
RSpec.describe "Generate submission swagger docs" do
  context "with API V1 Docs", type: :request, swagger_doc: "v1/live/swagger.yaml" do
    include_examples "GET submission"
  end

  context "with API V1 Docs (incl. smoke tests)", type: :request, swagger_doc: "v1/swagger.yaml" do
    include_examples "GET submission"
  end
end
