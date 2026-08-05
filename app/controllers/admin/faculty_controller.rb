class Admin::FacultyController < Admin::BaseController
  def index
    @faculty = User.where(role: :faculty).order(created_at: :desc)
  end

  def approve
    @faculty = User.where(role: :faculty).find(params[:id])
    @faculty.update!(is_approved: true)
    redirect_to admin_faculty_index_path, notice: "#{@faculty.full_name} approved."
  end

  def reject
    @faculty = User.where(role: :faculty).find(params[:id])
    @faculty.destroy
    redirect_to admin_faculty_index_path, notice: "#{@faculty.email} rejected and removed."
  end
end
