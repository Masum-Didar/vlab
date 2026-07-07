class ExperimentSchool < ApplicationRecord
  belongs_to :experiment
  belongs_to :school

  validates :experiment_id, uniqueness: { scope: :school_id }
end
