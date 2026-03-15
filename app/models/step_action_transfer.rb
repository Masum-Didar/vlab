class StepActionTransfer < ApplicationRecord
  belongs_to :step_action
  belongs_to :chemical
  belongs_to :source_container, class_name: "Container"
  belongs_to :target_container, class_name: "Container"
end
