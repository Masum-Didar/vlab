class StepAction < ApplicationRecord
  belongs_to :phase_step

  belongs_to :chemical, optional: true
  belongs_to :equipment, optional: true

  belongs_to :source_container, class_name: "Container", optional: true
  belongs_to :target_container, class_name: "Container", optional: true

  enum :action_type, { label_match: 0, chemical_match: 1, transfer: 2 }

  validates :action_type, presence: true

end