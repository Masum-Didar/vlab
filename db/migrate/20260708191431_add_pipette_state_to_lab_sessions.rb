class AddPipetteStateToLabSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :lab_sessions, :pipette_state, :jsonb, null: false, default: {}
  end
end
