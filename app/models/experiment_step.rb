class ExperimentStep < ApplicationRecord
  belongs_to :experiment
  belongs_to :experiment_phase

  validates :step_number, presence: true
  validates :instruction, presence: true

  default_scope { order(:step_number) }
end