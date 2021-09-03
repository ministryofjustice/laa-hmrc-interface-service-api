class ServiceAccountPopulator
  DATA_FILE = Rails.root.join('db/seed_data/service_accounts.yml').freeze

  def self.call
    new.call
  end

  def call
    seed_data.each { |seed_row| populate(seed_row) }.freeze
  end

  private

  def populate(seed_row)
    service_name, use_cases = seed_row
    record = ServiceAccount.find_by(service_name: service_name) || ServiceAccount.new
    record.update!(
      service_name: service_name,
      use_cases: use_cases
    )
  end

  def seed_data
    @seed_data ||= YAML.load_file(DATA_FILE)
  end
end
