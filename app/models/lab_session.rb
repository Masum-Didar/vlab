class LabSession < ApplicationRecord
  belongs_to :user
  belongs_to :experiment

  validates :current_phase, numericality: { greater_than_or_equal_to: 1 }

  def complete_phase!(phase_number)
    current = completed_phases || []
    return false if current.include?(phase_number)

    current << phase_number
    next_phase = phase_number + 1
    total_phases = experiment.experiment_phases.maximum(:position) || 1

    updates = { completed_phases: current }
    if next_phase <= total_phases
      updates[:current_phase] = next_phase
    end

    update!(updates)
  end

  def phase_completed?(phase_number)
    completed_phases&.include?(phase_number) || false
  end

  def all_phases_completed?
    total = experiment.experiment_phases.maximum(:position) || 1
    (completed_phases || []).size >= total
  end

  def can_access_phase?(phase_number)
    return true if phase_number == 1
    phase_completed?(phase_number - 1)
  end
end
