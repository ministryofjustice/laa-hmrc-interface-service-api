FactoryBot.define do
  factory :use_case do
    initialize_with { new(use_case) }

    use_case { 'one' }
  end
end
