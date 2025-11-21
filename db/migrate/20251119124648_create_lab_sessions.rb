class CreateLabSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :lab_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :experiment, null: false, foreign_key: true
      t.integer :status
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
