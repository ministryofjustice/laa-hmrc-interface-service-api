FactoryBot.define do
  factory :submission do
    status { :created }
    use_case { %i[one two three four].sample }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    nino { Faker::Base.regexify(Submission::NINO_REGEXP) }
    dob { Faker::Date.birthday.strftime }
    start_date { (Time.zone.today - 180).strftime }
    end_date { (Time.zone.today - 90).strftime }
    oauth_application_id { SecureRandom.uuid }
  end

  trait :processing do
    status { :processing }
  end

  trait :completed do
    status { :completed }
  end

  trait :failed do
    status { :failed }
  end

  trait :with_attachment do
    after :create do |submission|
      submission.result.attach(io: File.open("spec/fixtures/test_result.json"),
                               filename: "#{submission.id}.json",
                               content_type: "application/json",
                               key: "submission/result/#{submission.id}")
      submission.reload
    end
  end
  trait :failed_with_attachment do
    status { :failed }
    after :create do |submission|
      submission.result.attach(io: File.open("spec/fixtures/test_result_failed.json"),
                               filename: "#{submission.id}.json",
                               content_type: "application/json",
                               key: "submission/result/#{submission.id}")
      submission.reload
    end
  end
end
