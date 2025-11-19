class CreateExperimentChemicals < ActiveRecord::Migration[8.1]
  def change
    create_table :experiment_chemicals do |t|
      t.references :experiment, null: false, foreign_key: true
      t.references :chemical, null: false, foreign_key: true
      t.integer :quantity_default

      t.timestamps
    end
  end
end
