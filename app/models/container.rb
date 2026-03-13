class Container < ApplicationRecord
  has_many :source_step_actions, class_name: "StepAction", foreign_key: :source_container_id
  has_many :target_step_actions, class_name: "StepAction", foreign_key: :target_container_id
end
