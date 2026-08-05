class AddEquipmentToStepActionLabels < ActiveRecord::Migration[8.1]
  def change
    add_reference :step_action_labels, :equipment, foreign_key: true, null: true
  end
end
