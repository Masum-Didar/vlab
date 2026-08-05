class Admin::DashboardController < Admin::BaseController

  def index
    @experiments_count = Experiment.count
    @users_count       = User.count
    @active_count      = LabSession.where(status: :started).count rescue 0
    @pending_count     = Experiment.where(status: :pending).count
    @pending_faculty_count = User.where(role: :faculty, is_approved: false).count

    @completed_count   = Experiment.where(status: :completed).count
    @failed_count      = Experiment.where(status: :failed).count
    @avg_duration      = Experiment.average(:duration)&.round || 0

    @recent_experiments = Experiment.order(created_at: :desc).limit(5)
  end
end
