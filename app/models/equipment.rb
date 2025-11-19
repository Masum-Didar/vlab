class Equipment < ApplicationRecord
  has_many :experiment_equipments
  has_many :experiments, through: :experiment_equipments

  validates :name, presence: true
end
