class ApplicationUser < ApplicationRecord
  serialize :use_cases

  validates :use_cases, presence: true, inclusion: { in: (1..4) }
end
