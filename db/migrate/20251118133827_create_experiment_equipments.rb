class CreateExperimentEquipments < ActiveRecord::Migration[8.1]
  def change
    create_table :experiment_equipments do |t|
      t.references :experiment, null: false, foreign_key: true
      t.references :equipment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
