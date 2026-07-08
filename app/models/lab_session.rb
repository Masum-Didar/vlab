class LabSession < ApplicationRecord
  belongs_to :user
  belongs_to :experiment

  validates :current_phase, numericality: { greater_than_or_equal_to: 1 }

  DEFAULT_PIPETTE_STATE = {
    "has_tip" => false,
    "tip_generation" => 0,
    "last_transfer_tip_generation" => nil,
    "last_transfer_source" => nil,
    "last_transfer_target" => nil,
    "ejected_count" => 0
  }.freeze

  def pipette_status
    DEFAULT_PIPETTE_STATE.merge(pipette_state || {})
  end

  def attach_pipette_tip!
    state = pipette_status
    state["has_tip"] = true
    state["tip_generation"] = state["tip_generation"].to_i + 1
    update!(pipette_state: state)
  end

  def eject_pipette_tip!
    state = pipette_status
    state["has_tip"] = false
    state["ejected_count"] = state["ejected_count"].to_i + 1
    update!(pipette_state: state)
  end

  def record_pipette_transfer!(source:, target:)
    state = pipette_status
    state["last_transfer_tip_generation"] = state["tip_generation"].to_i
    state["last_transfer_source"] = source
    state["last_transfer_target"] = target
    update!(pipette_state: state)
  end

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
