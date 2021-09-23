class Submission < ApplicationRecord
  belongs_to :oauth_application, class_name: 'Doorkeeper::Application'
  has_one_attached :result

  USE_CASES = %w[one two three four].freeze
  validates :use_case, presence: true, inclusion: { in: USE_CASES, message: 'Invalid use case' }

  def as_json(*)
    super.except('id', 'status', 'created_at', 'updated_at', 'oauth_application_id')
  end
end
