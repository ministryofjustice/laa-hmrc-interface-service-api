require_relative "../../app/services/queue_name_service"

Sidekiq.configure_server do |config|
  config.logger = Rails.logger
  config.redis = { url: "redis://127.0.0.1:6380/5" } if Rails.env.development?
  config.capsule("use_case_one_capsule") do |cap|
    cap.concurrency = 1
    cap.queues = ["uc-one-#{QueueNameService.call}"]
  end
  config.capsule("use_case_two_capsule") do |cap|
    cap.concurrency = 1
    cap.queues = ["uc-two-#{QueueNameService.call}"]
  end
  config.capsule("use_case_three_capsule") do |cap|
    cap.concurrency = 1
    cap.queues = ["uc-three-#{QueueNameService.call}"]
  end
  config.capsule("use_case_four_capsule") do |cap|
    cap.concurrency = 1
    cap.queues = ["uc-four-#{QueueNameService.call}"]
  end
end

Sidekiq.configure_client do |config|
  config.logger = Rails.logger
  config.logger.level = Logger::WARN # prevent info output in tests
  config.redis = { url: "redis://127.0.0.1:6380/5" } if Rails.env.development?
end
