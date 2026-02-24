class AddDescriptionToChemicals < ActiveRecord::Migration[8.1]
  def change
    add_column :chemicals, :description, :text
  end
end
