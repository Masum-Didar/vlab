class ChangeStatusToIntegerInExperimentResults < ActiveRecord::Migration[8.1]
  def change
    change_column :experiment_results, :status, :integer, using: "status::integer"
  end
end
