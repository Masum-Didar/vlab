class ExperimentResult < ApplicationRecord
  belongs_to :user
  belongs_to :experiment
end
