class StepActionLabel < ApplicationRecord
  belongs_to :step_action
  belongs_to :equipment, optional: true

  validates :label_text, presence: true
end
