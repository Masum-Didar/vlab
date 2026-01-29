class Department < ApplicationRecord
  # The department belongs to the School (Tenant)
  acts_as_tenant :school
  belongs_to :school
  has_many :users

  validates :name, presence: true

end
