class QuizLog < ApplicationRecord
  acts_as_tenant :school, optional: true

  belongs_to :user
  belongs_to :assignment
  belongs_to :master_quiz

  validates :student_answer, presence: true
  validates :attempt_number, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
end
