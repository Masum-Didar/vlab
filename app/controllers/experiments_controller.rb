class ExperimentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_experiment, only: [:show, :lab]

  def index
    @experiments = Experiment.all
  end

  def show
  end

  def lab
  end

  private

  def set_experiment
    @experiment =
      if params[:id].present?
        Experiment.includes(experiment_phases: :phase_steps).find(params[:id])
      else
        Experiment.includes(experiment_phases: :phase_steps).find_by(title: "Gel Electrophoresis Lab") || Experiment.first
      end

    redirect_to experiments_path, alert: "No experiment has been set up yet." unless @experiment
  end
end
