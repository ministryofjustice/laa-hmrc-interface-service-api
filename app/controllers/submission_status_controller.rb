class SubmissionStatusController < ApplicationController
  def show
    submission = Submission.find(params.fetch(:id))
    render json: { submission: submission.id,
                   status: submission.status,
                   _links: [href: "#{request.base_url}/submission-status/#{submission.id}"] }
  rescue ActiveRecord::RecordNotFound
    render status: :not_found
  end
end
