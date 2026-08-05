class Submission < ApplicationRecord
  acts_as_tenant :school, optional: true

  belongs_to :user
  belongs_to :experiment

  enum :status, { pending: 0, completed: 1, graded: 2, failed: 3, rejected: 4 }
end
