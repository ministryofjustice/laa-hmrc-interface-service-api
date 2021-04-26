class CreateApplicationUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :application_users, id: :uuid do |t|
      t.string :name
      t.string :access_key
      t.string :secret_key
      t.text :use_cases, default: [].to_yaml

      t.timestamps
    end
  end
end
