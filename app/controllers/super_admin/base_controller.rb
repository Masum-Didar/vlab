class SuperAdmin::BaseController < ApplicationController
  layout "super_admin"

  before_action :authenticate_user!
  before_action :require_super_admin!

  private

  def require_super_admin!
    unless current_user.present? && current_user.super_admin?
      redirect_to root_path, alert: "You are not authorized."
    end
  end
end
