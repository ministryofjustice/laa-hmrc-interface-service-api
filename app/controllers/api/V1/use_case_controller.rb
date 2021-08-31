module Api
  module V1
    class UseCaseController < ApiController
      def submit
        submission = Submission.new(filtered_params.merge(status: 'created'))
        if submission.save
          render json: { id: submission.id }, status: :accepted
        else
          render json: submission.errors&.to_json, status: :bad_request
        end
      end

      def one
        result = ApplyGetTest.call('one', **transformed_params)
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
