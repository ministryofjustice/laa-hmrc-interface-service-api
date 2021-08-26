class CreateSubmissions < ActiveRecord::Migration[6.1]
  def change
    create_table :submissions, id: :uuid do |t|
      t.string :use_case, null: false
      t.string :last_name
      t.string :first_name
      t.string :dob
      t.string :nino
      t.string :start_date
      t.string :end_date
      t.string :status

      t.timestamps
    end
  end
end
