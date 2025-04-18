module Api
  module V1
    class SubmissionsController < ApiController
      class InvalidUseCaseError < StandardError; end

      class UnauthorisedApplicationError < StandardError; end
      rescue_from InvalidUseCaseError, with: :unauthorised_use_case
      rescue_from UnauthorisedApplicationError, with: :unauthorised_application

      def create
        raise InvalidUseCaseError, "Unauthorised use case" unless authorised_use_case?

        submission = Submission.new(filtered_params.merge(use_case: use_case_param,
                                                          status: "created",
                                                          oauth_application: doorkeeper_token.application))
        submission.save!
        process_submission(submission.id)
      rescue ActiveRecord::RecordInvalid
        render json: submission.errors&.to_json, status: :bad_request
      end

      def result
        raise UnauthorisedApplicationError, "Unauthorised application" unless authorised_application?

        render json: return_body, status: return_status
      rescue ActiveRecord::RecordNotFound
        render status: :not_found
      end

    private

      def return_status
        @return_status ||= if completed_but_no_attachment?
                             :internal_server_error
                           elsif completed_with_attachment? || submission.status.eql?("failed")
                             :ok
                           elsif !submission.status.eql?("completed")
                             :accepted
                           end
      end

      def return_body
        data_hash = if return_status.eql?(:ok)
                      JSON.parse(attachment.blob.download, symbolize_names: true)
                    elsif completed_but_no_attachment?
                      { code: "INCOMPLETE_SUBMISSION", message: "Process complete but no result available" }
                    else
                      { _links: [href: "#{request.base_url}/api/v1/submission/result/#{submission.id}"] }
                    end
        { submission: submission.id, status: submission.status }.merge(data_hash)
      end

      def unauthorised_use_case
        render json: { error: "Unauthorised use case" }.to_json, status: :bad_request
      end

      def unauthorised_application
        render json: { error: "Unauthorised application" }.to_json, status: :bad_request
      end

      def authorised_use_case?
        scopes_match_use_case = doorkeeper_token.application.scopes.to_a.map do |scope|
          scope.ends_with? use_case_param
        end
        scopes_match_use_case.any?
      end

      def use_case_param
        params.require(:use_case)
      end

      def filtered_params
        params.expect(filter: %i[use_case
                                 last_name
                                 first_name
                                 dob
                                 nino
                                 start_date
                                 end_date])
      end

      def submission
        @submission ||= Submission.find(params.fetch(:id))
      end

      def attachment
        @attachment ||= submission.result.attachment
      end

      def process_submission(id)
        queue = "uc-#{Submission.find(id).use_case}-#{QueueNameService.call}"
        SubmissionProcessWorker.set(queue:).perform_async(id)
        render json: { id:,
                       _links: [href: "#{request.base_url}/api/v1/submission/result/#{id}"] },
               status: :accepted
      end

      def completed_with_attachment?
        submission.status.eql?("completed") && attachment.present?
      end

      def completed_but_no_attachment?
        submission.status.eql?("completed") && attachment.nil?
      end

      def authorised_application?
        submission.oauth_application == doorkeeper_token.application
      end
    end
  end
end
