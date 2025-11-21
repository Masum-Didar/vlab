class DashboardController < ApplicationController
  before_action :authenticate_user!

  # def index
  #   @total_students = User.where(role: :student).count
  #   @total_experiments = Experiment.count
  #   @active_sessions = LabSession.where(status: :active).count
  #   @pending_submissions = Submission.where(status: :pending).count
  # end
  def index
    @total_students = User.where(role: :student).count
    @total_experiments = Experiment.count
    @active_sessions = LabSession.where(status: :active).count
    @pending_submissions = Submission.where(status: :pending).count

    # Limit table to last 5
    @recent_submissions = Submission.includes(:user, :experiment).order(created_at: :desc).limit(5)
  end
end
