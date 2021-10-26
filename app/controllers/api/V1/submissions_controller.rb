module Api
  module V1
    class SubmissionsController < ApiController
      class InvalidUseCaseError < StandardError; end

      class UnauthorisedApplicationError < StandardError; end
      rescue_from InvalidUseCaseError, with: :unauthorised_use_case
      rescue_from UnauthorisedApplicationError, with: :unauthorised_application

      def create
        raise InvalidUseCaseError, 'Unauthorised use case' unless authorised_use_case?

        submission = Submission.new(filtered_params.merge(use_case: use_case_param,
                                                          status: 'created',
                                                          oauth_application: doorkeeper_token.application))
        submission.save

        if submission.errors.empty?
          process_submission(submission.id)
        else
          render json: submission.errors&.to_json, status: :bad_request
        end
      end

      def status
        raise UnauthorisedApplicationError, 'Unauthorised application' unless authorised_application?

        render json: { submission: submission.id,
                       status: submission.status,
                       _links: [href: "#{request.base_url}/api/v1/submission/#{result_or_status}/#{submission.id}"] },
               status: return_status
      rescue ActiveRecord::RecordNotFound
        render status: :not_found
      end

      def result
        raise UnauthorisedApplicationError, 'Unauthorised application' unless authorised_application?

        render json: return_body, status: return_status
      rescue ActiveRecord::RecordNotFound
        render status: :not_found
      end

      private

      def return_status
        if completed_but_no_attachment?
          :internal_server_error
        elsif completed_with_attachment?
          :ok
        elsif !submission.status.eql?('completed')
          :accepted
        end
      end

      def return_body
        if completed_with_attachment?
          attachment.blob.download
        elsif completed_but_no_attachment?
          { code: 'INCOMPLETE_SUBMISSION', message: 'Process complete but no result available' }
        else
          { submission: submission.id, status: submission.status,
            _links: [href: "#{request.base_url}/api/v1/submission/status/#{submission.id}"] }
        end
      end

      def unauthorised_use_case
        render json: { error: 'Unauthorised use case' }.to_json, status: :bad_request
      end

      def unauthorised_application
        render json: { error: 'Unauthorised application' }.to_json, status: :bad_request
      end

      def authorised_use_case?
        doorkeeper_token.application.scopes.to_a.map do |scope|
          scope.ends_with? use_case_param
        end.any?
      end

      def use_case_param
        params.require(:use_case)
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

      def submission
        @submission ||= Submission.find(params.fetch(:id))
      end

      def attachment
        @attachment ||= submission.result.attachment
      end

      def process_submission(id)
        SubmissionProcessWorker.perform_async(id)
        render json: { id: id,
                       _links: [href: "#{request.base_url}/api/v1/submission/status/#{id}"] },
               status: :accepted
      end

      def completed_with_attachment?
        submission.status.eql?('completed') && attachment.present?
      end

      def completed_but_no_attachment?
        submission.status.eql?('completed') && attachment.nil?
      end

      def result_or_status
        submission.status.eql?('completed') ? 'result' : 'status'
      end

      def authorised_application?
        submission.oauth_application == doorkeeper_token.application
      end
    end
  end
end
