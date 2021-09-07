class Submission < ApplicationRecord
  has_one_attached :result
  attr_reader :data

  USE_CASES = %w[one two three four].freeze
  validates :use_case, presence: true, inclusion: { in: USE_CASES, message: 'Invalid use case' }

  def as_json(*)
    super.except('id', 'status', 'created_at', 'updated_at')
  end

  include SubmissionProcessable

  def process!
    @correlation_id = id
    @use_case = UseCase.new(use_case.to_sym)
    @data = OpenStruct.new(as_json.except('use_case'))
    @result = { data: [{ correlation_id: @correlation_id }] }
    data = request_and_extract_data(request_match_id)
    process_next_steps(data)
    result.attach(io: StringIO.new(@result.to_json),
                  filename: "#{id}.json",
                  content_type: 'application/json',
                  key: "submission/result/#{id}")
  end
end
