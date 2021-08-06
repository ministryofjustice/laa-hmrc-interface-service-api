class SmokeTestController < ApplicationController
  def call
    result = SmokeTest.call(smoke_test_params)
    render status: status, json: { "smoke_test_#{smoke_test_params}_result": result }
  end

  def health_check
    results = run_tests
    status = results.values.all?(true) ? 200 : 500
    render status: status, json: { smoke_test_result: results }
  end

  private

  def run_tests
    {
      use_case_one: REDIS.get('smoke-test-one'),
      use_case_two: REDIS.get('smoke-test-two'),
      use_case_three: REDIS.get('smoke-test-three'),
      use_case_four: REDIS.get('smoke-test-four')
    }
  end

  def smoke_test_params
    params.require(:use_case)
  end
end
