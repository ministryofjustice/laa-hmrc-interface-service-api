FactoryBot.define do
  factory :application_user do
    name { Faker::Company.name }
    access_key { SecureRandom.hex(13) }
    secret_key { SecureRandom.hex(64) }
    use_cases { [1] }
  end
end
