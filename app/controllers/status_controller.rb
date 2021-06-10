class StatusController < ApplicationController
  def health_check
    checks = {
      database: database_alive?,
      redis: redis_alive?
    }

    status = :bad_gateway unless checks.except(:sidekiq_queue).values.all?
    render status: status, json: { checks: checks }
  end

  def ping
    render json: {
      'build_date' => Settings.status.build_date,
      'build_tag' => Settings.status.build_tag,
      'app_branch' => Settings.status.app_branch
    }
  end

  private

  def database_alive?
    ActiveRecord::Base.connection.active?
  rescue PG::ConnectionBad
    false
  end

  def redis_alive?
    REDIS.ping.eql?('PONG')
  rescue StandardError
    false
  end
end
