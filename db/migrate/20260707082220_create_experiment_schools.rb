class CreateExperimentSchools < ActiveRecord::Migration[8.1]
  def change
    create_table :experiment_schools do |t|
      t.references :experiment, null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end

    add_index :experiment_schools, [:experiment_id, :school_id], unique: true
  end
end
