class AddContainerTypeToContainers < ActiveRecord::Migration[8.1]
  def change
    add_column :containers, :container_type, :string, null: false, default: "general"
  end
end
