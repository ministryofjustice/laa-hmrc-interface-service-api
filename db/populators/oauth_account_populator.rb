class OauthAccountPopulator
  DATA_FILE = Rails.root.join('db/seed_data/test_oauth_accounts.yml').freeze

  def self.call
    new.call
  end

  def call
    seed_data.each { |seed_row| populate(seed_row) }.freeze unless Settings.environment.eql?('live')
  end

  private

  def populate(seed_row)
    name, scopes, uid, secret = seed_row
    record = Doorkeeper::Application.find_by(name: name) || Doorkeeper::Application.new
    record.update!(
      name: name,
      scopes: scopes,
      uid: uid,
      secret: secret
    )
  end

  def seed_data
    @seed_data ||= YAML.load_file(DATA_FILE)
  end
end
