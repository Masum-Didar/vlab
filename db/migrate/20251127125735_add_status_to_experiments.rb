class AddStatusToExperiments < ActiveRecord::Migration[8.1]
  def change
    add_column :experiments, :status, :integer, default: 0, null: false
    add_column :experiments, :duration, :integer, default: 0 # optional
  end
end
