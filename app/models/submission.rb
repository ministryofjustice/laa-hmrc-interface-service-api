class Submission < ApplicationRecord
  belongs_to :oauth_application, class_name: "Doorkeeper::Application"
  has_one_attached :result

  NINO_REGEXP = /^[A-CEGHJ-PR-TW-Z]{1}[A-CEGHJ-NPR-TW-Z]{1}[0-9]{6}[A-DFM]{1}$/

  USE_CASES = %w[one two three four].freeze

  before_validation :normalise_nino

  validates :use_case, presence: true, inclusion: { in: USE_CASES }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validate :validate_nino
  validates :dob, date: { not_in_the_future: true }
  validates :start_date, date: { not_in_the_future: true }
  validates :end_date, date: { not_in_the_future: true }
  validate :end_date_after_start_date

  def as_json(*)
    super.except("id", "status", "created_at", "updated_at", "oauth_application_id")
  end

  def normalise_nino
    return if nino.blank?

    nino.delete!(" ")
    nino.upcase!
  end

  def validate_nino
    return if NINO_REGEXP.match?(nino)

    errors.add(:nino, "is not valid")
  end

private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    errors.add(:start_date, :invalid_timeline) if end_date < start_date
    errors.add(:end_date, :invalid_timeline) if end_date < start_date
  end
end
