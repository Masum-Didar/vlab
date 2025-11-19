class CreateChemicals < ActiveRecord::Migration[8.1]
  def change
    create_table :chemicals do |t|
      t.string :name
      t.string :formula
      t.string :state
      t.string :color_hex
      t.jsonb :properties

      t.timestamps
    end
  end
end
