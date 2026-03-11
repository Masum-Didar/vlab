class PhaseItem < ApplicationRecord
  belongs_to :experiment_phase
  validates :title, presence: true

end
