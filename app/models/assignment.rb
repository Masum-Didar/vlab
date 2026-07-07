class Assignment < ApplicationRecord
  acts_as_tenant :school

  belongs_to :classroom
  belongs_to :experiment
  belongs_to :faculty, class_name: "User"

  validates :faculty_id, presence: true

  enum :status, { draft: 0, active: 1, closed: 2 }
end
