Sidekiq.configure_server do |config|
  config.logger = Rails.logger
  config.redis = { url: 'redis://127.0.0.1:6379/5' } if Rails.env.development?
end

Sidekiq.configure_client do |config|
  config.logger = Rails.logger
  config.logger.level = Logger::WARN # prevent info output in tests
  config.redis = { url: 'redis://127.0.0.1:6379/5' } if Rails.env.development?
end
