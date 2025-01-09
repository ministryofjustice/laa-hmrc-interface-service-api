Rails.configuration.generators do |generators|
  generators.orm :active_record, primary_key_type: :uuid
  generators.test_framework :rspec
end
