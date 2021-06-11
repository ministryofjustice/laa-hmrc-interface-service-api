# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

Dir[Rails.root.join('db/seeds/*.rb')].each do |seed|
  load seed
end

Rails.logger.info 'Seeding completed'
