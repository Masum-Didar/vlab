class StepActionTransfer < ApplicationRecord
  belongs_to :step_action
  belongs_to :chemical
  belongs_to :source_container, class_name: "Container"
  belongs_to :target_container, class_name: "Container"

  validates :source_container_id, :target_container_id, presence: true
  validate :source_and_target_different

  def source_and_target_different
    if source_container_id == target_container_id
      errors.add(:target_container_id, "must be different from source")
    end
  end
end