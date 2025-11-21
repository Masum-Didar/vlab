class CreateSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :submissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :experiment, null: false, foreign_key: true
      t.integer :status
      t.jsonb :data

      t.timestamps
    end
  end
end
