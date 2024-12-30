Sidekiq.configure_server do |config|
  config.logger = Rails.logger
  config.redis = { url: "redis://127.0.0.1:6380/5" } if Rails.env.development?
  config.capsule("submission_capsules") do |cap|
    cap.concurrency = 1
    cap.queues = %w[uc_one_submissions uc_two_submissions uc_three_submissions uc_one_submissions]
  end
end

Sidekiq.configure_client do |config|
  config.logger = Rails.logger
  config.logger.level = Logger::WARN # prevent info output in tests
  config.redis = { url: "redis://127.0.0.1:6380/5" } if Rails.env.development?
end
