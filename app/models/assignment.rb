class Assignment < ApplicationRecord
  acts_as_tenant :school

  belongs_to :classroom
  belongs_to :experiment
  belongs_to :faculty, class_name: "User"

  validates :faculty_id, presence: true

  enum :status, { draft: 0, active: 1, closed: 2 }

  has_many :assignment_quizzes, dependent: :destroy
  has_many :master_quizzes, through: :assignment_quizzes
  has_many :quiz_logs, dependent: :destroy
end
