class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # Protect every page by default
  before_action :authenticate_user!

  # Configure Devise parameters
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected


  def after_sign_in_path_for(resource)
    # This logic determines where they go,
    # The 'layout' determines what it looks like when they get there.
    if resource.faculty?
      admin_dashboard_path
    else
      root_path
    end
  end

  def configure_permitted_parameters
    # Allow these fields during Sign Up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :role])

    # Allow these fields during Account Update
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :role])
  end
end
