class SchoolLandingController < ApplicationController
  # Skip authentication for school landing page
  skip_before_action :authenticate_user!
  
  before_action :load_school

  def index
    # If no school tenant, redirect to main landing page
    unless @school
      # Build main landing page URL (without subdomain)
      subdomain = extract_subdomain_from_request
      
      if subdomain.present?
        # We're on a subdomain but school not found - redirect to main domain
        if Rails.env.development?
          # For development, redirect to lvh.me (main domain)
          main_url = "http://lvh.me:#{request.port}"
        else
          # For production, redirect to main domain
          protocol = request.protocol
          base_domain = request.domain
          main_url = "#{protocol}#{base_domain}"
        end
        redirect_to main_url, 
                    alert: "School not found. Please check the subdomain.",
                    allow_other_host: true
      else
        # No subdomain - show main landing page
        # Redirect to the landing controller
        redirect_to landing_path, 
                    alert: "Please enter a valid school subdomain."
      end
      return
    end
    
    # School landing page - tenant is already set by set_tenant in ApplicationController
  end

  private

  def load_school
    # Try to get school from current tenant (set by ApplicationController)
    @school = ActsAsTenant.current_tenant
    
    # If no tenant set, try to find school from subdomain
    unless @school
      subdomain = extract_subdomain_from_request
      if subdomain.present?
        @school = School.find_by_subdomain(subdomain)
        if @school
          set_current_tenant(@school)
        end
      end
    end
  end
end
