class AddApprovalToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :is_approved, :boolean, default: false
    add_index :users, :is_approved
  end
end
