class Faculty::AssignmentsController < Faculty::BaseController
  before_action :set_classrooms, only: [:new, :create]

  def index
    @assignments = Assignment.where(faculty: current_user)
                             .includes(:classroom, :experiment)
                             .order(created_at: :desc)
  end

  def new
    @assignment = Assignment.new
    @experiments = Experiment.where(published: true).order(:title)
  end

  def create
    @assignment = Assignment.new(assignment_params)
    @assignment.faculty = current_user

    if @assignment.save
      redirect_to faculty_assignments_path, notice: "Assignment created successfully."
    else
      @experiments = Experiment.where(published: true).order(:title)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_classrooms
    @classrooms = Classroom.where(school: current_user.school).order(:name)
  end

  def assignment_params
    params.require(:assignment).permit(:classroom_id, :experiment_id, :due_date, :status)
  end
end
