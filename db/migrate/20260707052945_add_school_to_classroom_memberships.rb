class AddSchoolToClassroomMemberships < ActiveRecord::Migration[8.1]
  def change
    add_reference :classroom_memberships, :school, null: false, foreign_key: true
  end
end
