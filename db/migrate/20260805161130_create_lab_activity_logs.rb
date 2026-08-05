class CreateLabActivityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :lab_activity_logs do |t|
      t.references :school, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :lab_session, null: false, foreign_key: true
      t.references :experiment_phase, foreign_key: true
      t.references :phase_step, foreign_key: true
      t.string :action_type
      t.jsonb :metadata, default: {}, null: false
      t.boolean :is_error, default: false, null: false
      t.timestamps
    end
  end
end
