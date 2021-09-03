class ServiceAccount < ApplicationRecord

  USE_CASES = %w[one two three four].freeze
  validates :use_cases, presence: true, inclusion: { in: USE_CASES, message: 'Invalid use case'}

  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :delete_all,
           inverse_of: false # rubocop wants an inverse_of specified
                             # not sure if better to do this, ignore the rule
                             # or if there is a more correct inverse_of I could use

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :delete_all,
           inverse_of: false
end
