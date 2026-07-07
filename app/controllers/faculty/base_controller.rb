class Faculty::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate_user!
  before_action :require_faculty!
  before_action :require_approval!

  private

  def require_faculty!
    unless current_user.present? && current_user.faculty?
      redirect_to root_path, alert: "You are not authorized."
    end
  end

  def require_approval!
    if current_user.present? && current_user.pending_approval?
      sign_out current_user
      redirect_to new_user_session_path, alert: "Your account is pending approval. Please wait for an administrator to approve your account."
    end
  end
end
