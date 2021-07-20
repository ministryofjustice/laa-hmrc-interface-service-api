class SmokeTest
  def self.call
    new.call
  end

  def call
    JSON.parse(actual_response).eql?(JSON.parse(expected_response))
  end

  private

  def expected_response
    @expected_response ||= File.read('./spec/fixtures/smoke_tests/use_case_one.json')
  end

  def actual_response
    @actual_response ||= ApplyGetTest.new(first_name: smoke_test_settings.first_name,
                                          last_name: smoke_test_settings.last_name,
                                          nino: smoke_test_settings.nino,
                                          dob: smoke_test_settings.dob,
                                          start_date: smoke_test_settings.start_date,
                                          end_date: smoke_test_settings.end_date)
                                     .call(correlation_id: smoke_test_settings.correlation_id)
  end

  def smoke_test_settings
    @smoke_test_settings ||= Settings.smoke_test.use_case_one
  end
end
