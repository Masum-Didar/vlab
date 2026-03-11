class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # --- Tenancy & Hierarchy ---
  acts_as_tenant :school
  belongs_to :school
  belongs_to :department, optional: true # Optional in case Admin has no dept

  has_many :experiment_results, dependent: :destroy

  enum :role, { student: 0, faculty: 1, administrator: 2 }

  # Full name fallback
  def full_name
    if first_name.present? || last_name.present?
      "#{first_name} #{last_name}".strip
    else
      email.split("@").first.capitalize
    end
  end

  # Initials (like DR)
  def initials
    if first_name.present? || last_name.present?
      "#{first_name.to_s[0]}#{last_name.to_s[0]}".upcase
    else
      email[0..1].upcase
    end
  end

  # Role formatted like "Admin" / "Student"
  def role_title
    role.to_s.capitalize
  end
  def faculty?
    role == 'faculty' # or self.is_faculty (if you used a boolean)
  end
  def student?
    role == 'student' # or self.is_student (if you used a boolean)
  end
end
