class CreateExperimentResults < ActiveRecord::Migration[8.1]
  def change
    create_table :experiment_results do |t|
      t.references :user, null: false, foreign_key: true
      t.references :experiment, null: false, foreign_key: true
      t.jsonb :data
      t.string :status

      t.timestamps
    end
  end
end
