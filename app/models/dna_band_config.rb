class DnaBandConfig < ApplicationRecord
  belongs_to :experiment

  validates :sample_name, :well_number, :band_positions, presence: true
  validates :well_number, uniqueness: { scope: :experiment_id }

  def self.matches?(user_positions, expected_positions)
    user_positions = Array(user_positions).map(&:to_i).sort
    expected = Array(expected_positions).map(&:to_i).sort
    user_positions == expected
  end
end
