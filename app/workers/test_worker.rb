class TestWorker
  class SentryIgnoresThisSidekiqFailError < StandardError; end
  include Sidekiq::Worker
  attr_accessor :retry_count

  MAX_RETRIES = 3
  sidekiq_options queue: 'task', retry: MAX_RETRIES
  sidekiq_retries_exhausted do |msg, _ex|
    Sentry.capture_message <<~ERROR
      Moving #{msg['class']}##{msg['args'].first} to dead set, it failed with: #{msg['error_class']}/#{msg['error_message']}
    ERROR
  end

  def perform(*args)
    Rails.logger.info "running job started at #{args[0]}"
    # Simulate long running job
    sleep 20 unless Rails.env.eql?('test')
    # then fail!
    1 / 0
  rescue ZeroDivisionError
    raise if @retry_count.eql? MAX_RETRIES

    raise SentryIgnoresThisSidekiqFailError, "Retry #{@retry_count.to_i}: this shouldn't alert until all retries fail"
  end
end
