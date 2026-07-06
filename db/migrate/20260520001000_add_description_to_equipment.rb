class AddDescriptionToEquipment < ActiveRecord::Migration[8.1]
  def change
    add_column :equipment, :description, :text
  end
end
