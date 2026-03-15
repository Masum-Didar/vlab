class StepActionLabel < ApplicationRecord
  belongs_to :step_action

  validates :label_text, presence: true
end
