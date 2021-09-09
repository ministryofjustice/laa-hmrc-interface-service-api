module Api
  module V1
    class UseCaseController < ApiController
      def submit
        # if the service_account calling the API does not have appropriate
        # use_case access it will raise an error

        raise "Unauthorised used case" unless doorkeeper_token.application.scopes.to_a.map { |scope| scope.ends_with? filtered_params['use_case'] }.any?
        # raise "Unauthorised SERVICE ACCOUNT/USE_CASE #{ServiceAccount.find_by_id(doorkeeper_token.resource_owner_id).use_cases.to_a} " unless
        #   ServiceAccount.find_by_id(doorkeeper_token.resource_owner_id).use_cases.to_a.map { |use_case| use_case.ends_with? filtered_params['use_case'] }.any?

        submission = Submission.new(filtered_params.merge(status: 'created'))
        if submission.save
          SubmissionProcessWorker.perform_async(submission.id)
          render json: { id: submission.id,
                         _links: [href: "#{request.base_url}/api/v1/submission-status/#{submission.id}"] },
                 status: :accepted
        else
          render json: submission.errors&.to_json, status: :bad_request
        end
      end

      def one
        submission = Submission.create(filtered_params.merge(use_case: :one, status: 'created'))
        result = ApplyGetTest.call_with(submission)
        submission.result.attach(io: StringIO.new(result),
                                 filename: "#{submission.id}.json",
                                 content_type: 'application/json',
                                 key: "submission/result/#{submission.id}")
        render json: result
      end

      def two
        result = ApplyGetTest.call('two', **transformed_params)
        render json: result
      end

      def three
        result = ApplyGetTest.call('three', **transformed_params)
        render json: result
      end

      def four
        result = ApplyGetTest.call('four', **transformed_params)
        render json: result
      end

      private

      def filtered_params
        params.require(:filter).permit(:use_case,
                                       :last_name,
                                       :first_name,
                                       :dob,
                                       :nino,
                                       :start_date,
                                       :end_date)
      end

      def transformed_params
        filtered_params.to_hash.transform_keys(&:to_sym)
      end
    end
  end
end
