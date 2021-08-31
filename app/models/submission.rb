class Submission < ApplicationRecord
  has_one_attached :result

  USE_CASES = %w[one two three four].freeze
  validates :use_case, presence: true, inclusion: { in: USE_CASES, message: 'Invalid use case' }

  def as_json(*)
    super.except('id', 'status', 'created_at', 'updated_at')
  end
end
