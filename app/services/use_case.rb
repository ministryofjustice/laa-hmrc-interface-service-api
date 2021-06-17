class UseCase
  FOUR_HOURS = 14_400 # fours hours in seconds

  def initialize(use_case)
    @use_case = "use_case_#{use_case}"
    @bearer_token = bearer_token
  end

  def self.call(use_case)
    new(use_case)
  end

  def host
    Settings.credentials.send(@use_case).host
  end

  # :nocov:
  # This is ignored for coverage as it allows a legacy script to run
  # It should be removed once a new set of sidekiq jobs is created
  # that will allow a comparison before this is deleted
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
