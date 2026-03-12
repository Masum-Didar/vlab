class ExperimentPhase < ApplicationRecord
  belongs_to :experiment
  has_many :phase_steps, -> { order(:step_number) }, dependent: :destroy


  # has_many :experiment_steps, -> { order(:step_number) }, dependent: :destroy
  # has_many :phase_items, -> { order(:position) }, dependent: :destroy

  accepts_nested_attributes_for :phase_steps, allow_destroy: true
  # accepts_nested_attributes_for :experiment_steps, allow_destroy: true
  # accepts_nested_attributes_for :phase_items, allow_destroy: true

  validates :title, presence: true
end