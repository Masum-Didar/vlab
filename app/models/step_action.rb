class StepAction < ApplicationRecord
  belongs_to :phase_step

  # belongs_to :chemical, optional: true
  # belongs_to :equipment, optional: true

  has_many :step_action_labels, dependent: :destroy
  has_many :step_action_equipments, dependent: :destroy
  has_many :step_action_transfers, dependent: :destroy

  enum :action_type, { label_match: 0, equipment_use: 1, transfer: 2 }

  validates :action_type, presence: true

end