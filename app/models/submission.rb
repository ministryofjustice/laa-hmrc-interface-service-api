class Submission < ApplicationRecord
  USE_CASES = %w[one two three four].freeze
  validates :use_case, presence: true, inclusion: { in: USE_CASES, message: 'Invalid use case' }
end
