class OauthAccountPopulator
  DATA_FILE = Rails.root.join('db/seed_data/oauth_accounts.yml').freeze

  def self.call
    new.call
  end

  def call
    seed_data.each { |seed_row| populate(seed_row) }.freeze
  end

  private

  def populate(seed_row)
    name, scopes = seed_row
    record = Doorkeeper::Application.find_by(name: name) || Doorkeeper::Application.new
    record.update!(
      name: name,
      scopes: scopes
    )
  end

  def seed_data
    @seed_data ||= YAML.load_file(DATA_FILE)
  end
end
