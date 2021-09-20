module Api
  module V1
    class SubmissionsController < ApiController
      rescue_from ::StandardError, with: :deny_access

      def create
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

      def status
        render json: { submission: submission.id,
                       status: submission.status,
                       _links: [href: "#{request.base_url}/api/v1/submission/status/#{submission.id}"] }
      rescue ActiveRecord::RecordNotFound
        render status: :not_found
      end

      def result
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

      def submission
        @submission ||= Submission.find(params.fetch(:id))
      end

      def attachment
        @attachment ||= submission.result.attachment
      end

      def completed_with_attachment?
        submission.status.eql?('completed') && attachment.present?
      end

      def completed_but_no_attachment?
        submission.status.eql?('completed') && attachment.nil?
      end
    end
  end
end
