module Api
  module V1
    class UseCaseController < ApiController
      def submit
        submission = Submission.new(filtered_params.merge(status: 'created'))
        if submission.save
          SubmissionProcessWorker.perform_async(submission.id)
          render json: { id: submission.id, _links: [href: "#{request.base_url}/submission-status/#{submission.id}"] },
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
