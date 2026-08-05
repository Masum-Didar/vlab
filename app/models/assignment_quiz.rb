class AssignmentQuiz < ApplicationRecord
  acts_as_tenant :school, optional: true

  belongs_to :assignment
  belongs_to :master_quiz
end
