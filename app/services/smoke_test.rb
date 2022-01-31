class SmokeTest
  def initialize(use_case)
    @use_case = use_case
  end

  def self.call(use_case)
    new(use_case).call
  end

  def call
    actual = JSON.parse(actual_response)['data']
    expected = JSON.parse(expected_response)['data']
    diff = (actual - expected) + (expected - actual)
    result = diff.empty?
    REDIS.setex("smoke-test-#{@use_case}", 3600, result)
    result
  end

private

  def expected_response
    @expected_response ||= File.read("./spec/fixtures/smoke_tests/use_case_#{@use_case}.json")
  end

  def actual_response
    @actual_response ||= ApplyGetTest.new(@use_case,
                                          first_name: smoke_test_settings.first_name,
                                          last_name: smoke_test_settings.last_name,
                                          nino: smoke_test_settings.nino,
                                          dob: smoke_test_settings.dob,
                                          start_date: smoke_test_settings.start_date,
                                          end_date: smoke_test_settings.end_date)
                                     .call(correlation_id: smoke_test_settings.correlation_id)
  end

  def smoke_test_settings
    @smoke_test_settings ||= Settings.smoke_test.send("use_case_#{@use_case}")
  end
end
