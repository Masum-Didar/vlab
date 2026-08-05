class DropLegacyTables < ActiveRecord::Migration[8.1]
  def change
    drop_table :step_options if table_exists?(:step_options)
    drop_table :experiment_steps if table_exists?(:experiment_steps)
    drop_table :phase_items if table_exists?(:phase_items)
  end
end
