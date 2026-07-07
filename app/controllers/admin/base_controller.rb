# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  # 1. Force the use of views/layouts/admin.html.erb
  layout 'admin'

  before_action :authenticate_user!
  before_action :require_faculty!
  before_action :require_approval!

  private

  def require_faculty!
    unless current_user.present? && (current_user.faculty? || current_user.administrator?)
      redirect_to root_path, alert: "You are not authorized to access the Faculty Dashboard."
    end
  end

  def require_approval!
    if current_user.present? && current_user.pending_approval?
      sign_out current_user
      redirect_to new_user_session_path, alert: "Your account is pending approval. Please wait for an administrator to approve your account."
    end
  end
end