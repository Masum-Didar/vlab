class StepActionEquipment < ApplicationRecord
  belongs_to :step_action
  belongs_to :equipment
end
