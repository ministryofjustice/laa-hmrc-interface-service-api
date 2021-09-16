module Api
  module V1
    class SubmissionStatusController < ApiController
      def show
        submission = Submission.find(params.fetch(:id))
        render json: { submission: submission.id,
                       status: submission.status,
                       _links: [href: "#{request.base_url}/api/v1/submission-status/#{submission.id}"] }
      rescue ActiveRecord::RecordNotFound
        render status: :not_found
      end
    end
  end
end
