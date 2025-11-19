class ExperimentEquipment < ApplicationRecord
  belongs_to :experiment
  belongs_to :equipment
end
