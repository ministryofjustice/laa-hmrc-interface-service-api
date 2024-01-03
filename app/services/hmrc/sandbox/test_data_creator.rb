#
# Usage:
#
# A test user, "individual", must already exist with that nino. Test
# Users are created via the HMRC developer hub UI or the relevant API
# endpoint thereof.
#
# ```ruby
# creator = TestDataCreator.new(nino: "JA123456D", use_case: :one)
# creator.create!(endpoint: :paye, start_date: "2022-10-01".to_date, end_date: "2022-12-31".to_date)
# creator.create!(endpoint: :employment, start_date: start_date, end_date: end_date)
# ```
#
# NOTE: the payload is taken from fixture files that are git-crypted. In addition, the income/paye
# `paymentDate` in the payload must be within the range defined by start_date and end_date or data
# creation will fail.
#
module HMRC
  module Sandbox
    class HostError < StandardError; end
    class LiveError < StandardError; end
    class EndpointError < StandardError; end
    class UseCaseError < StandardError; end

    class TestDataCreator
      ENDPOINTS = %i[employment paye].freeze
      USE_CASES = %i[one two three four].freeze

      def initialize(nino:, use_case:)
        raise HostError, "Cannot run using non-test HMRC API host" unless using_test_host_credentials?
        raise LiveError, "Cannot run from live" unless Settings.environment.eql?("non-live")
        raise UseCaseError, "use_case must be :one to :four" unless use_case.in?(USE_CASES)

        @nino = nino
        @use_case = use_case
      end

      def create!(endpoint:, start_date:, end_date:)
        raise EndpointError, "endpoint must be :employment or :paye" unless endpoint.in?(ENDPOINTS)

        @endpoint = endpoint
        @start_date = start_date
        @end_date = end_date

        payload = send(:"#{@endpoint}_data").to_json
        response = RestClient.post(url, payload, headers)
        response.code.eql?(201)
      end

    private

      def using_test_host_credentials?
        Settings.credentials.host.match?("test") &&
          Settings.credentials.use_case_one.host.match?("test") &&
          Settings.credentials.use_case_two.host.match?("test") &&
          Settings.credentials.use_case_three.host.match?("test") &&
          Settings.credentials.use_case_four.host.match?("test")
      end

      def url
        "#{base_url}#{path}#{nino}#{query_params}"
      end

      def base_url
        "#{Settings.credentials.host}/individuals/integration-framework-test-support/individuals"
      end

      def path
        {
          employment: "/employment",
          paye: "/income/paye",
        }[@endpoint.to_sym]
      end

      def nino
        "/nino/#{@nino}"
      end

      def query_params
        "?startDate=#{@start_date.strftime('%Y-%m-%d')}&endDate=#{@end_date.strftime('%Y-%m-%d')}&useCase=#{laa_use_case}"
      end

      def laa_use_case
        {
          one: "LAA-C1", # apply
          two: "LAA-C2", # gross income
          three: "LAA-C3", # fraud
          four: "LAA-C4", # debt
        }[@use_case.to_sym]
      end

      def headers
        {
          "Content-Type" => "application/json",
          "Accept" => "application/vnd.hmrc.1.0+json",
          "Authorization" => "Bearer #{bearer_token}",
        }
      end

      def bearer_token
        @bearer_token ||= UseCase.new(@use_case).bearer_token
      end

      def paye_data
        JSON.parse(File.read("spec/fixtures/test_data/paye.json"))
      end

      def employment_data
        JSON.parse(File.read("spec/fixtures/test_data/employment.json"))
      end
    end
  end
end
