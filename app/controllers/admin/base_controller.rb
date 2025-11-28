# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  # 1. Force the use of views/layouts/admin.html.erb
  layout 'admin'

  before_action :authenticate_user!
  before_action :require_faculty!

  private

  def require_faculty!
    unless current_user.present? && current_user.faculty?
      redirect_to root_path, alert: "You are not authorized to access the Faculty Dashboard."
    end
  end
end