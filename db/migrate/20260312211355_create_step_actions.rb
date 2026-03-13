class CreateStepActions < ActiveRecord::Migration[8.1]
  def change
    create_table :step_actions do |t|
      t.references :phase_step, null: false, foreign_key: true

      t.integer :action_type
      t.string :label_name

      t.references :chemical, foreign_key: true
      t.references :equipment, foreign_key: true

      t.references :source_container, foreign_key: { to_table: :containers }
      t.references :target_container, foreign_key: { to_table: :containers }

      t.text :instruction
      t.string :image_url
      t.integer :position

      t.timestamps
    end
  end
end