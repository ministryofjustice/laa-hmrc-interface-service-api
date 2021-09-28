Sentry.init do |config|
  config.dsn = Settings.sentry.dsn unless Settings.sentry.environment.eql?('test')
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.environment = Settings.sentry.environment
  config.excluded_exceptions += %w[
    Errors::SentryIgnoresThisSidekiqFailError
  ]
  # Send 5% of non-ping transactions for performance monitoring
  # :nocov:
  config.traces_sampler = lambda do |sampling_context|
    # if this is the continuation of a trace, just use that decision (rate controlled by the caller)
    next sampling_context[:parent_sampled] unless sampling_context[:parent_sampled].nil?

    # transaction_context is the transaction object in hash form
    # keep in mind that sampling happens right after the transaction is initialized
    # for example, at the beginning of the request
    transaction_context = sampling_context[:transaction_context]

    # transaction_context helps you sample transactions with more sophistication
    # for example, you can provide different sample rates based on the operation or name
    op = transaction_context[:op]
    transaction_name = transaction_context[:name]

    case op
    when /request/
      # for Rails applications, transaction_name would be the request's
      # path (env["PATH_INFO"]) instead of "Controller#action"
      case transaction_name
      when /ping/
        0.0
      else
        0.05
      end
    else
      0.05
    end
    # :nocov:
  end
end
