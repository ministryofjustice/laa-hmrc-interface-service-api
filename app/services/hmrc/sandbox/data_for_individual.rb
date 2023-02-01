# Start here to create or retrieve test data from the Sandbox
#
# You must first have created a test "individual" using the
# [HMRC developer hub API or UI](https://developer.service.hmrc.gov.uk/api-test-user)
#
# Once you have a test individual you can
#   1. retrieve their details
#   2. append paye income
#   3. append paye employments
# as below:
#
# ```
# jimbob = HMRC::Sandbox::Individual.new("Jim", "Bob", "1951-01-02", "XX123456X")
# data_for_individual = HMRC::Sandbox::DataForIndividual.new(individual: jimbob, use_case: :one, start_date: "2022-10-01".to_date, end_date: "2022-12-31".to_date)
# data_for_individual.retrieve
# data_for_individual.append_paye
# data_for_individual.retrieve <-- you should see the appended paye
# data_for_individual.append_employment
# data_for_individual.retrieve <-- you should see the appended employment
#```
#
# NOTE: For paye "the `paymentDate` value provided in the POST body will be used to determine if
# the PAYE data sits within the date range provided in the query parameters,
# if they do not then the PAYE data will not be returned" HMRC developer documentation
#
#
module HMRC
  module Sandbox
    class DataForIndividual
      attr_reader :individual, :use_case, :start_date, :end_date

      def initialize(individual:, use_case:, start_date:, end_date:)
        @use_case = use_case
        @individual = individual
        @start_date = start_date
        @end_date = end_date
      end

      def append_paye
        creator = TestDataCreator.new(nino: individual.nino, use_case: use_case)
        creator.create!(endpoint: :paye, start_date: start_date, end_date: end_date)
      end

      def append_employment
        creator = TestDataCreator.new(nino: individual.nino, use_case: use_case)
        creator.create!(endpoint: :employment, start_date: start_date, end_date: end_date)
      end

      def retrieve
        submitter = TestSubmission.new(use_case,
                                       first_name: individual.first_name,
                                       last_name: individual.last_name,
                                       nino: individual.nino,
                                       dob: individual.dob,
                                       start_date: start_date,
                                       end_date: end_date)

        result = submitter.call
        JSON.parse(result)
      end
    end
  end
end
