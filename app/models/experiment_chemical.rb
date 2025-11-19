class ExperimentChemical < ApplicationRecord
  belongs_to :experiment
  belongs_to :chemical
end
