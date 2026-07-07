class CreateClassroomMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :classroom_memberships do |t|
      t.references :classroom, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :classroom_memberships, [:classroom_id, :user_id], unique: true
  end
end
