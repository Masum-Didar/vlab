class AddConfigToStepActions < ActiveRecord::Migration[8.1]
  def change
    add_column :step_actions, :config, :jsonb, default: {}, null: false
  end
end
