class CreateStepActionTransfers < ActiveRecord::Migration[8.1]
  def change
    create_table :step_action_transfers do |t|
      t.references :step_action, null: false, foreign_key: true
      t.integer :source_container_id
      t.integer :target_container_id
      t.references :chemical, null: false, foreign_key: true
      t.float :quantity

      t.timestamps
    end
  end
end
