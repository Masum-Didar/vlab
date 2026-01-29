class AddStructureToUsersAndTables < ActiveRecord::Migration[8.1]
  def change
    # 1. USERS: Link to School (for Tenancy) AND Department (for Organization)
    add_reference :users, :school, foreign_key: true, index: true
    add_reference :users, :department, foreign_key: true, index: true

    # 2. DATA: Link strictly to the SCHOOL (The Tenant)
    # We use school_id for tenancy because it's the top-level security wall.
    add_reference :experiment_results, :school, foreign_key: true, index: true
    add_reference :lab_sessions, :school, foreign_key: true, index: true
    add_reference :submissions, :school, foreign_key: true, index: true

    # 3. EXPERIMENTS: Link to School (Hybrid approach)
    add_reference :experiments, :school, foreign_key: true, index: true
  end
end
