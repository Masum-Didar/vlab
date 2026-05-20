class ExperimentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_experiment, only: [:show, :lab]

  def index
    @experiments = Experiment.includes(experiment_phases: :phase_steps).where(published: true).order(created_at: :desc)
  end

  def show
  end

  def lab
  end

  private

  def set_experiment
    @experiment = Experiment.includes(experiment_phases: { phase_steps: :step_actions }).find(params[:id])

    return if @experiment.published? || current_user.faculty?

    redirect_to experiments_path, alert: "This experiment is not published yet."
  end
end
