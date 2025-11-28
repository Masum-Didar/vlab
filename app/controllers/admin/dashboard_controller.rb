class Admin::DashboardController < Admin::BaseController

  def index
    @experiments_count = Experiment.count
    @users_count       = User.count
    @active_count      = 12 # Example
    @pending_count     = Experiment.where(status: :pending).count

    @completed_count   = Experiment.where(status: :completed).count
    @failed_count      = Experiment.where(status: :failed).count
    @avg_duration      = Experiment.average(:duration)&.round || 0

    @recent_experiments = Experiment.order(created_at: :desc).limit(5)
  end
end
