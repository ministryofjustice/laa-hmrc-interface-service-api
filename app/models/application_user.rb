class ApplicationUser < ApplicationRecord
  has_many :tasks, dependent: :destroy

  serialize :use_cases

  validates :use_cases, presence: true, inclusion: { in: (1..4) }
end
