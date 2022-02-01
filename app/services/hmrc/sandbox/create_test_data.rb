module HMRC
  module Sandbox
    class ProductionError < StandardError; end
    class TypeError < StandardError; end

    class CreateTestData
      TYPES = %i[employment paye].freeze

      def initialize(type, *dates)
        raise HMRC::Sandbox::ProductionError, "Cannot run from production" if Settings.environment.eql?("production")
        raise HMRC::Sandbox::TypeError, "Type must be :employment or :paye" unless type.in?(TYPES)

        @type = type
        @dates = dates
        build_dates
        @app = "apply"
        @token = UseCase.new(:one).bearer_token
      end

      def self.call(type, *dates)
        new(type, *dates).call
      end

      def call
        payload = send("#{@type}_data").to_json
        response = RestClient.post(url, payload, headers)
        response.code.eql?(201)
      end

    private

      def build_dates
        if @dates == []
          @end_date = Date.yesterday
          @start_date = @end_date.prev_month(3)
        else
          @end_date = Date.parse(@dates[1]) || Date.yesterday
          @start_date = Date.parse(@dates[0]) || @end_date.prev_month(3)
        end
      end

      def url
        "#{base_url}#{path}#{nino}#{variables}"
      end

      def base_url
        "#{Settings.credentials.host}/individuals/integration-framework-test-support/individuals"
      end

      def path
        {
          employment: "/employment",
          paye: "/income/paye",
        }[@type.to_sym]
      end

      def nino
        "/nino/#{Settings.smoke_test.use_case_one.nino}"
      end

      def variables
        "?startDate=#{@start_date.strftime('%Y-%m-%d')}&endDate=#{@end_date.strftime('%Y-%m-%d')}&useCase=#{use_case}"
      end

      def use_case
        {
          apply: "LAA-C1",
          gross_income: "LAA-C2",
          fraud: "LAA-C3",
          debt: "LAA-C4",
        }[@app.to_sym]
      end

      def headers
        {
          "Content-Type" => "application/json",
          "Accept" => "application/vnd.hmrc.1.0+json",
          "Authorization" => "Bearer #{@token}",
        }
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
