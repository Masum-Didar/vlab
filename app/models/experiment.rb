class Experiment < ApplicationRecord
  has_many :experiment_steps, dependent: :destroy
  has_many :experiment_chemicals, dependent: :destroy
  has_many :experiment_equipments, dependent: :destroy
  has_many :chemicals, through: :experiment_chemicals
  has_many :equipment, through: :experiment_equipments

  has_many :experiment_results, dependent: :destroy

  validates :title, presence: true
  enum :status, { pending: 0, started: 1, completed: 2, failed: 3 }

end
