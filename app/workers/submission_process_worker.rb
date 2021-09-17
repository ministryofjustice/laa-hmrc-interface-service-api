class SubmissionProcessWorker
  include Sidekiq::Worker
  attr_accessor :retry_count

  MAX_RETRIES = 3
  sidekiq_options queue: 'submissions', retry: MAX_RETRIES

  def perform(submission_id)
    submission = Submission.find(submission_id)

    if @retry_count.to_i >= MAX_RETRIES
      submission.update!(status: 'failed')
      Sentry.capture_message("Retry attempts exhausted for submission: #{submission.id}")
      return
    end

    SubmissionService.call(submission)
    submission.update!(status: 'processed')
  end
end
