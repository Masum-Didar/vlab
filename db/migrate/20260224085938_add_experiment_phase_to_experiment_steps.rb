class AddExperimentPhaseToExperimentSteps < ActiveRecord::Migration[8.1]
  def change
    add_reference :experiment_steps, :experiment_phase, null: false, foreign_key: true
  end
end
