class CreateStepActionLabels < ActiveRecord::Migration[8.1]
  def change
    create_table :step_action_labels do |t|
      t.references :step_action, null: false, foreign_key: true
      t.string :label_text
      t.string :image_url
      t.boolean :correct_match
      t.integer :position

      t.timestamps
    end
  end
end
