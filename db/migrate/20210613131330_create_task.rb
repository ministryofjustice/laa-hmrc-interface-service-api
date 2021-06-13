class CreateTask < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks, id: :uuid do |t|
      t.references :application_user, foreign_key: true, type: :uuid, index: true
      t.string :use_case
      t.json :data
      t.integer :status, default: 0
      t.integer :calls_started
      t.integer :calls_completed
      t.integer :result, default: 0
      t.json :outcome
      t.timestamps
    end
  end
end
