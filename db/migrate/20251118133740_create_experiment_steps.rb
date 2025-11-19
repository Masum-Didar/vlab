class CreateExperimentSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :experiment_steps do |t|
      t.references :experiment, null: false, foreign_key: true
      t.integer :step_number
      t.text :instruction
      t.jsonb :expected_action

      t.timestamps
    end
  end
end
