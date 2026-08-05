class LabActivityLog < ApplicationRecord
  acts_as_tenant :school, optional: true

  belongs_to :user
  belongs_to :lab_session
  belongs_to :experiment_phase, optional: true
  belongs_to :phase_step, optional: true

  validates :action_type, presence: true
end
