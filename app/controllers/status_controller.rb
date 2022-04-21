class StatusController < ApplicationController
  skip_before_action :doorkeeper_authorize!, only: %i[health_check ping]

  def health_check
    checks = {
      database: database_alive?,
      redis: redis_alive?,
      sidekiq: sidekiq_alive?,
      sidekiq_queue: sidekiq_queue_healthy?,
    }

    status = :bad_gateway unless checks.except(:sidekiq_queue).values.all?
    render status:, json: { checks: }
  end

  def ping
    render json: {
      "build_date" => Settings.status.build_date,
      "build_tag" => Settings.status.build_tag,
      "app_branch" => Settings.status.app_branch,
    }
  end

private

  def database_alive?
    ActiveRecord::Base.connection.active?
  rescue PG::ConnectionBad
    false
  end

  def redis_alive?
    REDIS.ping.eql?("PONG")
  rescue StandardError
    false
  end

  def sidekiq_alive?
    ps = Sidekiq::ProcessSet.new
    !ps.size.zero?
  rescue StandardError
    false
  end

  def sidekiq_queue_healthy?
    dead = Sidekiq::DeadSet.new
    retries = Sidekiq::RetrySet.new
    dead.size.zero? && retries.size.zero?
  rescue StandardError
    false
  end
end
