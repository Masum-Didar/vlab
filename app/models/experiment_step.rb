class ExperimentStep < ApplicationRecord
  belongs_to :experiment

  validates :step_number, presence: true
  validates :instruction, presence: true

  default_scope { order(:step_number) }
end
