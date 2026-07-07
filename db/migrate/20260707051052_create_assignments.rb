class CreateAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :assignments do |t|
      t.references :classroom, null: false, foreign_key: true
      t.references :experiment, null: false, foreign_key: true
      t.references :faculty, null: false, foreign_key: { to_table: :users }
      t.datetime :due_date
      t.integer :status
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
