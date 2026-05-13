class Container < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :container_type, presence: true

  has_many :source_transfers,
           class_name: "StepActionTransfer",
           foreign_key: :source_container_id

  has_many :target_transfers,
           class_name: "StepActionTransfer",
           foreign_key: :target_container_id
end
