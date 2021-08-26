module Api
  module V1
    class UseCaseController < ApiController
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
        params.require(:filter).permit(:last_name,
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
