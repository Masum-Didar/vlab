class SchoolRegistrationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :school_name, :string
  attribute :subdomain, :string
  attribute :admin_first_name, :string
  attribute :admin_last_name, :string
  attribute :admin_email, :string
  attribute :admin_password, :string
  attribute :admin_password_confirmation, :string

  attr_reader :school, :user

  validates :school_name, presence: true
  validates :subdomain, presence: true,
            format: { with: /\A[a-z0-9]([a-z0-9-]*[a-z0-9])?\z/i, 
                     message: "can only contain letters, numbers, and hyphens" }
  validates :admin_first_name, presence: true
  validates :admin_last_name, presence: true
  validates :admin_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :admin_password, presence: true, length: { minimum: 6 }
  validates :admin_password_confirmation, presence: true

  validate :subdomain_uniqueness
  validate :email_uniqueness
  validate :password_confirmation_match

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      # Create school
      @school = School.create!(
        name: school_name,
        subdomain: subdomain.downcase.strip
      )

      # Set current tenant for user creation
      ActsAsTenant.current_tenant = @school

      # Create admin user
      @user = User.create!(
        first_name: admin_first_name,
        last_name: admin_last_name,
        email: admin_email,
        password: admin_password,
        password_confirmation: admin_password_confirmation,
        role: :administrator,
        school: @school
      )
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    # Add model-specific errors to the form
    if e.record.is_a?(School)
      e.record.errors.each { |error| errors.add(error.attribute, error.message) }
    elsif e.record.is_a?(User)
      e.record.errors.each do |error|
        # Map user errors to form field names
        attribute = error.attribute
        attribute = "admin_#{attribute}" if [:email, :password, :password_confirmation].include?(attribute)
        errors.add(attribute, error.message)
      end
    else
      errors.add(:base, e.message)
    end
    false
  end

  private

  def subdomain_uniqueness
    return if subdomain.blank?

    normalized_subdomain = subdomain.downcase.strip
    if School.exists?(["LOWER(subdomain) = ?", normalized_subdomain])
      errors.add(:subdomain, "has already been taken")
    end
  end

  def email_uniqueness
    return if admin_email.blank?

    # Check if email already exists (globally, not per tenant)
    if User.exists?(email: admin_email.downcase.strip)
      errors.add(:admin_email, "has already been taken")
    end
  end

  def password_confirmation_match
    return if admin_password.blank? || admin_password_confirmation.blank?

    if admin_password != admin_password_confirmation
      errors.add(:admin_password_confirmation, "doesn't match password")
    end
  end
end
