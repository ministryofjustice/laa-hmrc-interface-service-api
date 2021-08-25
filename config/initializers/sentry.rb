Sentry.init do |config|
  config.dsn = Settings.sentry.dsn unless Settings.sentry.environment.eql?('test')
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.environment = Settings.sentry.environment
  config.excluded_exceptions += %w[
    TestWorker::SentryIgnoresThisSidekiqFailError
  ]
  # Send 5% of transactions for performance monitoring
  config.traces_sample_rate = 0.05
  # or
  # config.traces_sampler = lambda do |_context|
  #   true
  # end
end
