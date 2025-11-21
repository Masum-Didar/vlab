class LabSession < ApplicationRecord
  belongs_to :user
  belongs_to :experiment
end
