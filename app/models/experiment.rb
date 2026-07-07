class Experiment < ApplicationRecord
  has_many :experiment_phases, -> { order(:position) }, dependent: :destroy
  # has_many :experiment_steps, dependent: :destroy

  has_many :experiment_chemicals, dependent: :destroy
  has_many :experiment_equipments, dependent: :destroy
  has_many :experiment_results, dependent: :destroy
  has_many :dna_band_configs, -> { order(:well_number) }, dependent: :destroy

  accepts_nested_attributes_for :experiment_phases, allow_destroy: true

  validates :title, presence: true
  enum :status, { pending: 0, started: 1, completed: 2, failed: 3 }
end
