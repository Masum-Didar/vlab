class ClassroomMembership < ApplicationRecord
  acts_as_tenant :school

  belongs_to :classroom
  belongs_to :user

  validates :user_id, uniqueness: { scope: :classroom_id }
end
