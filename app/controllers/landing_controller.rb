class LandingController < ApplicationController
  # Skip authentication for landing page
  skip_before_action :authenticate_user!
  
  def index
    # This action should only be reached via the /landing route
    # The root route goes to SchoolLandingController which handles subdomain logic
    # If someone accesses /landing directly, show the main landing page
  end

  def redirect_to_tenant
    subdomain = params[:subdomain]&.strip&.downcase
    
    if subdomain.blank?
      flash[:alert] = "Please enter a subdomain."
      redirect_to root_path
      return
    end

    school = School.find_by_subdomain(subdomain)
    
    if school
      # Redirect to the school landing page on the subdomain
      redirect_to subdomain_url(subdomain), allow_other_host: true
    else
      flash[:alert] = "School with subdomain '#{subdomain}' not found."
      redirect_to root_path
    end
  end

  private

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
