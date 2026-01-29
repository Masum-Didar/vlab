class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # Protect every page by default
  before_action :authenticate_user!

  # Configure Devise parameters
  before_action :configure_permitted_parameters, if: :devise_controller?
  set_current_tenant_through_filter
  before_action :set_tenant
  
  # Handle OPTIONS requests for CORS preflight
  def options
    head :ok
  end

  protected

  def extract_subdomain_from_request
    # Extract subdomain from request host
    # For development: subdomain.lvh.me:3000 or subdomain.localhost:3000
    # For production: subdomain.example.com
    host = request.host
    return nil if host.blank?
    
    # Remove port if present
    host = host.split(':').first
    
    # Split by dots
    parts = host.split('.')
    
    # Don't treat 'www' as a subdomain
    return nil if parts.first&.downcase == 'www'
    
    # For lvh.me (development subdomain testing): 
    # - lvh.me -> no subdomain (2 parts)
    # - subdomain.lvh.me -> subdomain (3 parts)
    # For localhost:
    # - localhost -> no subdomain (1 part)
    # - subdomain.localhost -> subdomain (2 parts)
    # For production: 
    # - example.com -> no subdomain (2 parts)
    # - subdomain.example.com -> subdomain (3 parts)
    
    # Check if we're on a known base domain (no subdomain)
    base_domains = ['lvh.me', 'localhost', '127.0.0.1']
    return nil if base_domains.include?(host.downcase)
    
    # For lvh.me, we need 3 parts to have a subdomain (subdomain.lvh.me)
    if host.include?('lvh.me')
      return nil if parts.length <= 2
      subdomain = parts.first
      return subdomain if subdomain.present? && subdomain != 'www'
    end
    
    # For localhost, we need 2 parts to have a subdomain (subdomain.localhost)
    if host.include?('localhost')
      return nil if parts.length <= 1
      subdomain = parts.first
      return subdomain if subdomain.present? && subdomain != 'www'
    end
    
    # For production domains, we need 3+ parts to have a subdomain
    if parts.length >= 3
      subdomain = parts.first
      return subdomain if subdomain.present? && subdomain != 'www'
    end
    
    nil
  end

  private
  def set_tenant
    # First, try to get subdomain from request
    subdomain = extract_subdomain_from_request
    
    if subdomain.present?
      school = School.find_by_subdomain(subdomain)
      if school
        set_current_tenant(school)
        return
      end
    end
    
    # Fallback: if user is logged in, use their school
    if current_user&.school
      set_current_tenant(current_user.school)
    else
      set_current_tenant(nil)
    end
  end

  def after_sign_in_path_for(resource)
    # This logic determines where they go,
    # The 'layout' determines what it looks like when they get there.
    if resource.administrator? || resource.faculty?
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
