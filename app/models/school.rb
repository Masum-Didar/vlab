class School < ApplicationRecord
  has_many :departments, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :experiment_results, dependent: :destroy

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: { case_sensitive: false },
            format: { with: /\A[a-z0-9]([a-z0-9-]*[a-z0-9])?\z/i, 
                     message: "can only contain letters, numbers, and hyphens" }

  # Find school by subdomain (case-insensitive)
  def self.find_by_subdomain(subdomain)
    return nil if subdomain.blank?
    where("LOWER(subdomain) = ?", subdomain.downcase).first
  end
end
