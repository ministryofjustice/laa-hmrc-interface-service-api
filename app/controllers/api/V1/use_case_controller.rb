module Api
  module V1
    class UseCaseController < ApiController
      rescue_from ::StandardError, with: :deny_access

      def submit
        raise 'Unauthorised use case' unless authorised_use_case?

        submission = Submission.new(filtered_params.merge(status: 'created'))

        return unless submission.save

        SubmissionProcessWorker.perform_async(submission.id)
        render json: { id: submission.id,
                       _links: [href: "#{request.base_url}/api/v1/submission-status/#{submission.id}"] },
               status: :accepted
        #  TO DO show errors when the request does not include all required data
        # else
        #   render json: submission.errors&.to_json, status: :bad_request
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

      def deny_access
        render json: { error: 'Unauthorised use case' }.to_json, status: :bad_request
      end

      def authorised_use_case?
        doorkeeper_token.application.scopes.to_a.map do |scope|
          scope.ends_with? filtered_params['use_case']
        end.any?
      end

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
