class Faculty::ProgressController < Faculty::BaseController
  def index
    @students = User.where(school: current_user.school, role: :student).order(:first_name)
    @experiments = Experiment.where(school: current_user.school).order(:title)

    @stats = {}
    @students.each do |student|
      sessions = LabSession.where(user: student)
      completed = sessions.sum { |s| s.completed_phases&.size || 0 }
      total = sessions.sum { |s| s.experiment.experiment_phases.size }
      @stats[student.id] = {
        total_sessions: sessions.size,
        phases_completed: completed,
        phases_total: total,
        progress_pct: total > 0 ? ((completed.to_f / total) * 100).round : 0
      }
    end
  end

  def show
    @student = User.where(school: current_user.school, role: :student).find(params[:id])
    @sessions = LabSession.where(user: @student).includes(:experiment).order(created_at: :desc)
    @results = ExperimentResult.where(user: @student).includes(:experiment).order(created_at: :desc)
  end
end
