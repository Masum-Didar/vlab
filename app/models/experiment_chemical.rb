class ExperimentChemical < ApplicationRecord
  belongs_to :experiment
  belongs_to :chemical

  validates :quantity_default, numericality: true, allow_nil: true
end
