class Classroom < ApplicationRecord
  acts_as_tenant :school

  belongs_to :school
  has_many :classroom_memberships, dependent: :destroy
  has_many :students, through: :classroom_memberships, source: :user
  has_many :assignments, dependent: :destroy

  validates :name, presence: true
end
