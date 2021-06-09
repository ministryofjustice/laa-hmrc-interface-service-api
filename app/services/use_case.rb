class UseCase
  FOUR_HOURS = 14_400 # fours hours in seconds

  def initialize(use_case)
    @use_case = "use_case_#{use_case}"
    @bearer_token = bearer_token
  end

  # :nocov:
  def run_sync_test(first_name, last_name, date_of_birth, nino)
    Benchmark.measure { SyncTest.new(first_name, last_name, date_of_birth, nino).call }.real
  end
  # :nocov:

  private

  def bearer_token
    generate_new_token if current_token.nil?
    current_token
  end

  def generate_new_token
    new_token = BearerToken.call(@use_case)
    REDIS.setex("#{@use_case}_bearer_token", FOUR_HOURS, new_token)
  end

  def current_token
    REDIS.get("#{@use_case}_bearer_token")
  end
end
