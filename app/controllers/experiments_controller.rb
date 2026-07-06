class ExperimentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_experiment, only: [:show, :lab, :run_step]
  before_action :set_lab_session, only: [:lab, :run_step]

  def index
    @experiments = Experiment.includes(experiment_phases: :phase_steps).where(published: true).order(created_at: :desc)
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

    action = step.step_actions.find_by(action_type: action_type) if action_type.present?
    validation = validate_step_action(action, action_data) if action

    if validation&.dig(:valid) == false
      return render json: { error: validation[:message] }, status: :unprocessable_entity
    end

    all_steps_complete = phase.phase_steps.all? do |s|
      s.step_actions.all? { |a| params[:completed_action_ids]&.include?(a.id.to_s) }
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
      if data[:tip_changed] == false
        return { valid: false, message: "Contamination warning: Change pipette tip between samples!" }
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
    end
    { valid: true }
  end
end
