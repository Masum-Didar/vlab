class SuperAdmin::AdminsController < SuperAdmin::BaseController
  def index
    @admins = User.where(role: :administrator).includes(:school).order(created_at: :desc)
  end

  def approve
    @admin = User.where(role: :administrator).find(params[:id])
    @admin.update!(is_approved: true)
    redirect_to super_admin_admins_path, notice: "#{@admin.full_name} approved."
  end

  def reject
    @admin = User.where(role: :administrator).find(params[:id])
    @admin.destroy
    redirect_to super_admin_admins_path, notice: "#{@admin.email} rejected and removed."
  end
end
