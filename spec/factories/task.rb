FactoryBot.define do
  factory :task do
    application_user
    data { payload }
    use_case { :one }
    calls_started { 0 }
    calls_completed { 0 }

    trait :with_jwt do
      data { create_jwt_with(payload, application_user.secret_key) }
    end
  end
end

def payload
  {
    'first_name' => Faker::Name.first_name,
    'last_name' => Faker::Name.last_name,
    'nino' => Faker::Base.regexify(NINO_REGEXP),
    'dob' => Faker::Date.birthday,
    'from' => Date.yesterday,
    'to' => Date.yesterday - 3.months
  }
end

def create_jwt_with(payload, secret)
  JWT.encode payload, secret, 'HS512'
end
