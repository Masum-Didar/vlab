class LabSessionsController < ApplicationController
  before_action :set_lab_session, only: %i[ show edit update destroy ]

  def index
    @lab_sessions = LabSession.all
  end

  def show; end

  def new
    @lab_session = LabSession.new
  end

  def create
    @lab_session = LabSession.new(lab_session_params)
    if @lab_session.save
      redirect_to @lab_session, notice: "Lab session created."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @lab_session.update(lab_session_params)
      redirect_to @lab_session, notice: "Lab session updated."
    else
      render :edit
    end
  end

  def destroy
    @lab_session.destroy
    redirect_to lab_sessions_path, notice: "Lab session deleted."
  end

  private

  def set_lab_session
    @lab_session = LabSession.find(params[:id])
  end

  def lab_session_params
    params.require(:lab_session).permit(:user_id, :experiment_id, :status, :started_at, :ended_at)
  end
end
