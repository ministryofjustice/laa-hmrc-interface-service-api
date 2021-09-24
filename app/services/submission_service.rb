class SubmissionService
  attr_reader :data

  include SubmissionProcessable

  def initialize(use_case, submission)
    @use_case = UseCase.new(use_case)
    @submission = submission
    @data = OpenStruct.new(@submission.as_json.except('use_case'))
  end

  def self.call(submission)
    use_case = submission.use_case.to_sym
    new(use_case, submission).call(correlation_id: submission.id)
  end

  def call(correlation_id: SecureRandom.uuid)
    @correlation_id = correlation_id
    @result = { data: [{ correlation_id: @correlation_id }] }
    data = request_and_extract_data(request_match_id)
    process_next_steps(data)
  rescue Errors::ClientDetailsMismatchError
    @result[:data] << { error: 'submitted client details could not be found in HMRC service' }
    raise
  ensure
    @submission.result.attach(io: StringIO.new(@result.to_json), filename: "#{@submission.id}.json",
                              content_type: 'application/json', key: "submission/result/#{@submission.id}")
  end
end
