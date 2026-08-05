class PhaseStep < ApplicationRecord
  belongs_to :experiment_phase
  has_many :step_actions, -> { order(:position) }, dependent: :destroy

  accepts_nested_attributes_for :step_actions, allow_destroy: true
  validates :instruction, presence: true

  has_many :master_quizzes, dependent: :destroy
end
