class SubmissionService
  attr_reader :submission

  include SubmissionProcessable

  def initialize(use_case, submission)
    @use_case = UseCase.new(use_case)
    @submission = submission
  end

  def self.call(submission)
    use_case = submission.use_case.to_sym
    new(use_case, submission).call(correlation_id: submission.id)
  end

  def call(correlation_id: SecureRandom.uuid)
    @correlation_id = correlation_id
    @result = { data: [{ correlation_id: @correlation_id, use_case: @use_case.use_case }] }
    data = request_and_extract_data(request_match_id)
    process_next_steps(data)
  rescue Errors::CitizenDetailsMismatchError
    @result[:data] << { error: "submitted client details could not be found in HMRC service" }
    raise
  ensure
    @submission.result.attach(io: StringIO.new(@result.to_json),
                              filename: "#{@submission.id}.json",
                              content_type: "application/json",
                              key: "submission/result/#{@submission.id}-attached-at-#{Time.current.to_f}")
  end
end
