NINO_REGEXP = /^[A-CEGHJ-PR-TW-Z]{1}[A-CEGHJ-NPR-TW-Z]{1}[0-9]{6}[A-DFM]{1}$/

FactoryBot.define do
  factory :submission do
    id { SecureRandom.uuid }
    status { :created }
    use_case { %i[one two three four].sample }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    nino { Faker::Base.regexify(NINO_REGEXP) }
    dob { Faker::Date.birthday }
    start_date { Faker::Date.backward(days: 180) }
    end_date { start_date + 3.months }
  end

  trait :in_progress do
    status { :in_progress }
  end
end
