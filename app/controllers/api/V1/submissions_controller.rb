module Api
  module V1
    class SubmissionsController < ApiController
      def show
        render status: :accepted unless submission.status.eql? 'completed'
        render status: :internal_server_error if completed_but_no_attachment?
        render json: attachment.blob.download if completed_with_attachment?
      rescue ActiveRecord::RecordNotFound
        render status: :not_found
      end

      private

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
