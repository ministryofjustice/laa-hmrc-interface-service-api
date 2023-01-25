Sidekiq.configure_server do |config|
  config.logger = Rails.logger
end

Sidekiq.configure_client do |config|
  config.logger = Rails.logger
  config.logger.level = Logger::WARN # prevent info output in tests
end
