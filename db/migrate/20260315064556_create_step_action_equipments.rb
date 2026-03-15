class CreateStepActionEquipments < ActiveRecord::Migration[8.1]
  def change
    create_table :step_action_equipments do |t|
      t.references :step_action, null: false, foreign_key: true
      t.references :equipment, null: false, foreign_key: true
      t.string :instruction
      t.integer :position

      t.timestamps
    end
  end
end
