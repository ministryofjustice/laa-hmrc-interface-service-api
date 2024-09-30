class OauthAccountPopulator
  def self.call
    new.call
  end

  def call
    seed_data.each { |seed_row| populate(seed_row) }.freeze unless Settings.environment.eql?("live")
  end

private

  def populate(seed_row)
    record = Doorkeeper::Application.find_by(name: seed_row["name"]) || Doorkeeper::Application.new

    record.update!(
      name: seed_row["name"],
      scopes: seed_row["scopes"],
      uid: seed_row["uid"],
      secret: seed_row["secret"],
    )
  end

  def seed_data
    @seed_data ||= JSON.parse(test_oauth_accounts_json)
  end

  def test_oauth_accounts_json
    @test_oauth_accounts_json ||= ENV.fetch("TEST_OAUTH_ACCOUNTS_JSON", nil)
  end
end
