# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Rails.logger.debug "Seeding the database...\n"
Dir[Rails.root.join("db/populators/*.rb")].each do |seed_file|
  load seed_file
end

OauthAccountPopulator.call

Rails.logger.debug "Seeding complete."
