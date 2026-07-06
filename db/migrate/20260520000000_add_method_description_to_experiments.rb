class AddMethodDescriptionToExperiments < ActiveRecord::Migration[8.1]
  def change
    add_column :experiments, :method_description, :text
  end
end
