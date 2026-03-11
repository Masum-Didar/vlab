class CreatePhaseItems < ActiveRecord::Migration[8.1]
  def change
    create_table :phase_items do |t|
      t.references :experiment_phase, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :position

      t.timestamps
    end
  end
end
