Sentry.init do |config|
  config.dsn = Settings.sentry.dsn
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.environment = Settings.sentry.environment

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 0.5
  # or
  # config.traces_sampler = lambda do |_context|
  #   true
  # end
end
