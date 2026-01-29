class SchoolRegistrationsController < ApplicationController
  # Skip authentication for school registration
  skip_before_action :authenticate_user!
  # Skip tenant setting during registration
  skip_before_action :set_tenant

  def new
    @school_registration = SchoolRegistrationForm.new
  end

  def create
    @school_registration = SchoolRegistrationForm.new(school_registration_params)

    if @school_registration.save
      # Sign in the admin user
      sign_in(@school_registration.user, scope: :user)
      
      # Redirect to the school's subdomain landing page
      # They'll see the school landing page and can navigate to admin dashboard from there
      base_url = subdomain_url(@school_registration.school.subdomain)
      redirect_to base_url, 
                  notice: "School registered successfully! Welcome to VLab.",
                  allow_other_host: true
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def school_registration_params
    params.require(:school_registration_form).permit(
      :school_name,
      :subdomain,
      :admin_first_name,
      :admin_last_name,
      :admin_email,
      :admin_password,
      :admin_password_confirmation
    )
  end

  def subdomain_url(subdomain)
    # Build URL with subdomain
    # For development: http://subdomain.lvh.me:3000
    # For production: https://subdomain.example.com
    if Rails.env.development?
      port = request.port
      "http://#{subdomain}.lvh.me:#{port}"
    else
      # In production, you'll need to configure your domain
      # This assumes you're using a wildcard domain
      protocol = request.protocol
      base_domain = request.domain
      "#{protocol}#{subdomain}.#{base_domain}"
    end
  end
end
