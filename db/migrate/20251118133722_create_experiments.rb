class CreateExperiments < ActiveRecord::Migration[8.1]
  def change
    create_table :experiments do |t|
      t.string :title
      t.text :description
      t.integer :difficulty
      t.boolean :published
      t.jsonb :config

      t.timestamps
    end
  end
end
