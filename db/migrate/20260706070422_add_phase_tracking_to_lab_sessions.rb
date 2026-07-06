class AddPhaseTrackingToLabSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :lab_sessions, :current_phase, :integer, default: 1, null: false
    add_column :lab_sessions, :completed_phases, :jsonb, default: []
  end
end
