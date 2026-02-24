class CreateExperimentPhases < ActiveRecord::Migration[8.1]
  def change
    create_table :experiment_phases do |t|
      t.references :experiment, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :position

      t.timestamps
    end
  end
end
