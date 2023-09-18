Sidekiq.configure_server do |config|
  config.logger = Rails.logger unless Rails.env.development?
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1") }
end

Sidekiq.configure_client do |config|
  config.logger = Rails.logger
  config.logger.level = Logger::WARN # prevent info output in tests
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1") }
end
