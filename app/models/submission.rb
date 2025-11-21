class Submission < ApplicationRecord
  belongs_to :user
  belongs_to :experiment
end
