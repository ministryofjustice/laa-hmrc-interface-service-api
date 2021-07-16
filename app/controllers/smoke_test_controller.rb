class SmokeTestController < ApplicationController
  def call
    result = SmokeTest.call
    status = result.eql?(true) ? 200 : 500
    render status: status, json: { smoke_test_result: result }
  end
end
