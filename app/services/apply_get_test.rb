# :nocov:
class ApplyGetTest
  attr_reader :submission

  include SubmissionProcessable

  def initialize(use_case, **args)
    return unless args.keys.difference(%i[first_name last_name nino dob start_date end_date]).empty?

    @use_case = UseCase.new(use_case)
    @submission = JSON.parse({
      first_name: args[:first_name],
      last_name: args[:last_name],
      nino: args[:nino],
      dob: args[:dob],
      start_date: args[:start_date],
      end_date: args[:end_date]
    }.to_json, object_class: Submission)
  end

  def self.call(use_case, **args)
    new(use_case, **args).call
  end

  def self.call_with(submission)
    use_case = submission.use_case.to_sym
    values = submission.as_json.except('use_case').symbolize_keys
    new(use_case, **values).call(correlation_id: submission.id)
  end

  def call(correlation_id: SecureRandom.uuid)
    @correlation_id = correlation_id
    @result = { data: [{ correlation_id: @correlation_id }] }
    data = request_and_extract_data(request_match_id)
    process_next_steps(data)
    @result.to_json
  end
end
# :nocov:
