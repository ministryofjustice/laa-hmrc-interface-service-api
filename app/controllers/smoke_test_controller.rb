class SmokeTestController < ApplicationController
  skip_before_action :doorkeeper_authorize!, only: %i[call health_check]

  def call
    result = SmokeTest.call(smoke_test_params)
    render status: result ? 200 : 500, json: { "smoke_test_#{smoke_test_params}_result": result }
  end

  def health_check
    results = run_tests
    status = results.values.all?(true) ? 200 : 500
    render status:, json: { smoke_test_result: results }
  end

private

  def run_tests
    {
      use_case_one: redis.get("smoke-test-one"),
      use_case_two: redis.get("smoke-test-two"),
      use_case_three: redis.get("smoke-test-three"),
      use_case_four: redis.get("smoke-test-four"),
    }
  end

  def smoke_test_params
    params.require(:use_case)
  end

  def redis(*args)
    Sidekiq.redis { |r| return r }
  end
end
