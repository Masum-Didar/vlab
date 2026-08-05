class MasterQuiz < ApplicationRecord
  acts_as_tenant :school, optional: true

  belongs_to :experiment
  belongs_to :phase_step

  has_many :assignment_quizzes, dependent: :destroy
  has_many :quiz_logs, dependent: :destroy

  validates :question, presence: true
  validates :question_type, presence: true
  validates :correct_answer, presence: true
end
