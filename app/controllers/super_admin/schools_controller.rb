class SuperAdmin::SchoolsController < SuperAdmin::BaseController
  def index
    @schools = School.order(:name)
  end

  def show
    @school = School.find(params[:id])
    @experiments = Experiment.order(:title)
    @assigned_ids = @school.experiment_schools.pluck(:experiment_id)
  end

  def toggle_experiment
    @school = School.find(params[:id])
    experiment = Experiment.find(params[:experiment_id])

    es = @school.experiment_schools.find_by(experiment_id: experiment.id)
    if es
      es.destroy
      notice = "Experiment removed from school."
    else
      @school.experiment_schools.create!(experiment_id: experiment.id)
      notice = "Experiment assigned to school."
    end

    redirect_to super_admin_school_path(@school), notice: notice
  end
end
