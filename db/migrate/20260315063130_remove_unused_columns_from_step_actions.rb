class RemoveUnusedColumnsFromStepActions < ActiveRecord::Migration[8.1]
  def change
    remove_column :step_actions, :label_name, :string
    remove_column :step_actions, :chemical_id, :integer
    remove_column :step_actions, :equipment_id, :integer
    remove_column :step_actions, :source_container_id, :integer
    remove_column :step_actions, :target_container_id, :integer
    remove_column :step_actions, :image_url, :string
  end
end
