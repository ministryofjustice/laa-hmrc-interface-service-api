class Submission < ApplicationRecord
  belongs_to :oauth_application, class_name: 'Doorkeeper::Application'
  has_one_attached :result

  NINO_REGEXP = /^[A-CEGHJ-PR-TW-Z]{1}[A-CEGHJ-NPR-TW-Z]{1}[0-9]{6}[A-DFM]{1}$/

  USE_CASES = %w[one two three four].freeze

  before_validation :normalise_nino

  validates :use_case, presence: true, inclusion: { in: USE_CASES, message: 'Invalid use case' }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validate :validate_nino
  validates_date :dob, on_or_before: :today
  validates_date :start_date, on_or_before: :today
  validates_date :end_date, on_or_before: :today, after: :start_date

  def as_json(*)
    super.except('id', 'status', 'created_at', 'updated_at', 'oauth_application_id')
  end

  def normalise_nino
    return if nino.blank?

    nino.delete!(' ')
    nino.upcase!
  end

  def validate_nino
    return if NINO_REGEXP.match?(nino)

    errors.add(:nino, 'is not valid')
  end
end
