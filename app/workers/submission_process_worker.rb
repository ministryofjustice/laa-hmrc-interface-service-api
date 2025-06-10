class SubmissionProcessWorker
  include Sidekiq::Worker
  attr_accessor :retry_count

  MAX_RETRIES = 3
  sidekiq_options retry: MAX_RETRIES
  sidekiq_retries_exhausted do |msg, _ex|
    Sentry.capture_message <<~ERROR
      Moving #{msg['class']}##{msg['args'].first} to dead set, it failed with: #{msg['error_class']}/#{msg['error_message']}
    ERROR
  end

  def perform(submission_id)
    submission = Submission.find(submission_id)
    submission.update!(status: "processing")

    SubmissionService.call(submission)
    submission.update!(status: "completed")
  rescue Errors::CitizenDetailsMismatchError
    submission.update!(status: "failed")
  rescue StandardError
    submission.update!(status: "failed") && raise if @retry_count >= MAX_RETRIES

    raise Errors::SentryIgnoresThisSidekiqFailError, retry_error_message(submission_id)
  end

private

  def retry_error_message(submission_id)
    "Retry #{@retry_count.to_i} for SubmissionProcessWorker: #{submission_id}"
  end
end
