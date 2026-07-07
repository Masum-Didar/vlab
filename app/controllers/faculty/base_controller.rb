class Faculty::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate_user!
  before_action :require_faculty!

  private

  def require_faculty!
    unless current_user.present? && current_user.faculty?
      redirect_to root_path, alert: "You are not authorized."
    end
  end
end
