class SuperAdmin::DashboardController < SuperAdmin::BaseController
  def index
    @schools_count = School.count
    @experiments_count = Experiment.count
    @admins_pending = User.where(role: :administrator, is_approved: false).count
    @faculty_pending = User.where(role: :faculty, is_approved: false).count
    @total_users = User.count
  end
end
