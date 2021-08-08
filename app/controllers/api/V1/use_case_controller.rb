# :nocov:
# nocov added on creation as this is a placeholder controller until it
# can be extended
module Api
  module V1
    class UseCaseController < ApplicationController
      def index
        all_params = { use_case: :one }.merge(transformed_params)
        result = ApplyGetTest.call(all_params)
        render json: result
      end

      private

      def filtered_params
        params.require(:filter).permit(:last_name,
                                       :first_name,
                                       :date_of_birth,
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
# :nocov:
