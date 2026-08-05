class Faculty::AssignmentsController < Faculty::BaseController
  before_action :set_classrooms, only: [:new, :create, :edit, :update]
  before_action :set_assignment, only: [:edit, :update, :destroy]

  def index
    @assignments = Assignment.where(faculty: current_user)
                             .includes(:classroom, :experiment)
                             .order(created_at: :desc)
  end

  def new
    @assignment = Assignment.new
    @experiments = Experiment.where(published: true).order(:title)
    @all_quizzes = MasterQuiz.all.includes(:experiment)
  end

  def create
    @assignment = Assignment.new(assignment_params)
    @assignment.faculty = current_user

    if @assignment.save
      redirect_to faculty_assignments_path, notice: "Assignment created successfully."
    else
      @experiments = Experiment.where(published: true).order(:title)
      @all_quizzes = MasterQuiz.all.includes(:experiment)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @experiments = Experiment.where(published: true).order(:title)
    @all_quizzes = MasterQuiz.all.includes(:experiment)
  end

  def update
    if @assignment.update(assignment_params)
      redirect_to faculty_assignments_path, notice: "Assignment updated successfully."
    else
      @experiments = Experiment.where(published: true).order(:title)
      @all_quizzes = MasterQuiz.all.includes(:experiment)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @assignment.destroy
    redirect_to faculty_assignments_path, notice: "Assignment deleted successfully."
  end

  private

  def set_classrooms
    @classrooms = Classroom.where(school: current_user.school).order(:name)
  end

  def set_assignment
    @assignment = Assignment.where(faculty: current_user).find(params[:id])
  end

  def assignment_params
    params.require(:assignment).permit(:classroom_id, :experiment_id, :due_date, :status, master_quiz_ids: [])
  end
end
