class Chemical < ApplicationRecord
  has_many :experiment_chemicals
  has_many :experiments, through: :experiment_chemicals

  validates :name, presence: true
  validates :state, inclusion: { in: %w[solid liquid gas aqueous] }
end
