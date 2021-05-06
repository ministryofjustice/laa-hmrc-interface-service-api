class StatusController < ApplicationController
  def status
    checks = {
      database: database_alive?
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
end
