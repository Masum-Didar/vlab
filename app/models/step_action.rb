class StepAction < ApplicationRecord
  belongs_to :phase_step

  # belongs_to :chemical, optional: true
  # belongs_to :equipment, optional: true

  has_many :step_action_labels, dependent: :destroy
  has_many :step_action_equipments, dependent: :destroy
  has_many :step_action_transfers, dependent: :destroy

  enum :action_type, {
    label_match: 0,
    equipment_use: 1,
    transfer: 2,
    instruction: 3,
    equipment_connect: 4,
    quiz_input: 5,
    label_connect: 6,
    voltage_set: 9
  }

  validates :action_type, presence: true

end
