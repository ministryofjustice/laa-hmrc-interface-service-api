class CreateServiceAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :service_accounts, id: :uuid do |t|
      t.text :use_cases, array: true, default: []
      t.string :service_name, null: false

      t.timestamps
    end
  end
end
