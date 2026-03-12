class PhaseStep < ApplicationRecord
  belongs_to :experiment_phase
  validates :instruction, presence: true
end
