class ExperimentResult < ApplicationRecord
  belongs_to :user
  belongs_to :experiment

  enum :status, { started: 0, completed: 1, failed: 2 }

  # data = JSON output from simulation
end
