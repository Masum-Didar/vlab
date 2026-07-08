class ExperimentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_experiment, only: [:show, :lab, :run_step]
  before_action :set_lab_session, only: [:lab, :run_step]

  def index
    @experiments = Experiment.includes(experiment_phases: :phase_steps).where(published: true).order(created_at: :desc)

    if current_user.school.present?
      assigned_ids = current_user.school.experiment_schools.pluck(:experiment_id)
      @experiments = @experiments.where(id: assigned_ids) if assigned_ids.any?
    end

    if current_user.student?
      @assignments = Assignment.where(classroom: current_user.classroom_ids)
                               .includes(:experiment, :classroom)
                               .active
                               .order(due_date: :asc)
    end
  end

  def show
  end

  def lab
  end

  def run_step
    phase_number = params[:phase_number].to_i
    step_number = params[:step_number].to_i
    action_type = params[:action_type]
    action_data = params[:action_data] || {}

    unless @lab_session.can_access_phase?(phase_number)
      return render json: { error: "Complete the previous phase first." }, status: :unprocessable_entity
    end

    phase = @experiment.experiment_phases.find_by(position: phase_number)
    unless phase
      return render json: { error: "Phase not found." }, status: :not_found
    end

    step = phase.phase_steps.find_by(step_number: step_number)
    unless step
      return render json: { error: "Step not found." }, status: :not_found
    end

    actions = step.step_actions.order(:position)
    actions = actions.where(action_type: action_type) if action_type.present? && actions.many? && !actions.exists?(action_type: "transfer")

    validation = validate_and_process_step_actions(actions, action_data)

    if validation&.dig(:valid) == false
      return render json: { error: validation[:message] }, status: :unprocessable_entity
    end

    all_steps_complete = phase.phase_steps.all? do |s|
      params[:completed_step_ids]&.include?(s.id.to_s)
    end

    if all_steps_complete
      @lab_session.complete_phase!(phase_number)
    end

    render json: {
      success: true,
      current_phase: @lab_session.current_phase,
      completed_phases: @lab_session.completed_phases,
      phase_completed: all_steps_complete
    }
  end

  private

  def set_experiment
    @experiment = Experiment.includes(experiment_phases: { phase_steps: :step_actions }).find(params[:id])

    return if @experiment.published? || current_user.faculty?

    redirect_to experiments_path, alert: "This experiment is not published yet."
  end

  def set_lab_session
    @lab_session = LabSession.find_or_create_by!(
      user: current_user,
      experiment: @experiment
    ) do |session|
      session.current_phase = 1
      session.completed_phases = []
    end
  rescue ActiveRecord::RecordInvalid => e
    if request.format.json?
      render json: { error: "Could not start lab session: #{e.message}" }, status: :unprocessable_entity
    else
      redirect_to experiments_path, alert: "Could not start lab session: #{e.message}"
    end
  end

  def validate_and_process_step_actions(actions, data)
    result = { valid: true }

    LabSession.transaction do
      actions.each do |action|
        validation = validate_step_action(action, data)
        if validation[:valid] == false
          result = validation
          raise ActiveRecord::Rollback
        end

        process_step_action(action)
      end
    end

    result
  end

  def validate_step_action(action, data)
    case action.action_type
    when "label_match"
      correct = action.step_action_labels.where(correct_match: true).pluck(:label_text)
      selected = data[:selected_labels] || []
      missing = correct - selected
      if missing.any?
        return { valid: false, message: "Missing labels: #{missing.join(', ')}" }
      end
    when "transfer"
      transfer = action.step_action_transfers.first
      source = transfer&.source_container&.name || action.config&.dig("source") || action.config&.dig("sample") || action.instruction
      target = transfer&.target_container&.name || action.config&.dig("target") || action.config&.dig("well") || action.instruction

      validation = validate_pipette_transfer(source: source, target: target)
      return validation if validation[:valid] == false
    when "gel_band_match"
      selections = data[:band_selections].is_a?(String) ? JSON.parse(data[:band_selections]) : (data[:band_selections] || {})
      configs = action.phase_step&.experiment_phase&.experiment&.dna_band_configs || []
      incorrect = []

      configs.each do |config|
        well_key = (config.well_number - 1).to_s
        user_positions = selections[well_key] || []
        unless DnaBandConfig.matches?(user_positions, config.band_positions)
          incorrect << config.sample_name
        end
      end

      if incorrect.any?
        return { valid: false, message: "Incorrect bands for: #{incorrect.join(', ')}. Check the band positions and try again." }
      end
    when "pipette_tip_attach"
      if @lab_session.pipette_status["has_tip"]
        return { valid: false, message: "Eject the used tip before attaching a fresh one." }
      end
    when "pipette_eject"
      unless @lab_session.pipette_status["has_tip"]
        return { valid: false, message: "Click 'Eject tip' to remove the used tip." }
      end
    when "voltage_set"
      if data[:voltage].to_i != 70
        return { valid: false, message: "Voltage must be set to exactly 70V." }
      end
    when "quiz_input"
      expected = action.config&.dig("expected_answer")
      if expected.present? && data[:answer]&.strip&.downcase != expected.strip.downcase
        return { valid: false, message: "Incorrect answer. Please try again." }
      end
    when "gel_prep"
      prep_data = data[:gel_prep_data].is_a?(String) ? JSON.parse(data[:gel_prep_data]) : (data[:gel_prep_data] || {})
      unless prep_data["all_done"] == true || prep_data["all_done"] == "true"
        return { valid: false, message: "Complete all gel preparation steps." }
      end
    when "gel_run"
      run_data = data[:gel_run_data].is_a?(String) ? JSON.parse(data[:gel_run_data]) : (data[:gel_run_data] || {})
      unless run_data["complete"] == true || run_data["complete"] == "true"
        return { valid: false, message: "Wait for the electrophoresis run to complete." }
      end
    end
    { valid: true }
  end

  def validate_pipette_transfer(source:, target:)
    state = @lab_session.pipette_status

    unless state["has_tip"]
      return { valid: false, message: "Attach a fresh pipette tip before loading a sample." }
    end

    previous_source = state["last_transfer_source"]
    reused_tip = state["last_transfer_tip_generation"].present? &&
                 state["last_transfer_tip_generation"].to_i == state["tip_generation"].to_i

    if previous_source.present? && previous_source != source && reused_tip
      return { valid: false, message: "Contamination warning: eject the used tip and attach a fresh tip before changing samples." }
    end

    { valid: true, source: source, target: target }
  end

  def process_step_action(action)
    case action.action_type
    when "pipette_tip_attach"
      @lab_session.attach_pipette_tip!
    when "pipette_eject"
      @lab_session.eject_pipette_tip! if @lab_session.pipette_status["has_tip"]
    when "transfer"
      transfer = action.step_action_transfers.first
      source = transfer&.source_container&.name || action.config&.dig("source") || action.config&.dig("sample") || action.instruction
      target = transfer&.target_container&.name || action.config&.dig("target") || action.config&.dig("well") || action.instruction
      @lab_session.record_pipette_transfer!(source: source, target: target)
    end
  end
end
