# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

[
  ["Beaker A", "beaker"],
  ["Beaker B", "beaker"],
  ["Test Tube 1", "test_tube"],
  ["Test Tube 2", "test_tube"],
  ["Conical Flask", "flask"],
  ["Measuring Cylinder", "measuring_cylinder"],
  ["Pipette", "pipette"]
].each do |name, container_type|
  ActsAsTenant.without_tenant do
    container = Container.find_or_initialize_by(name: name)
    container.container_type = container_type
    container.save!
  end
end

# Super Admin account (bypass tenant scoping)
ActsAsTenant.without_tenant do
  super_admin = User.find_or_initialize_by(email: "superadmin@vlab.com")
  super_admin.update!(
    first_name: "Super",
    last_name: "Admin",
    role: :super_admin,
    is_approved: true,
    password: "password123",
    password_confirmation: "password123"
  )
end
puts "Super Admin created: superadmin@vlab.com / password123"

load(Rails.root.join("db/seeds/gel_electrophoresis.rb"))
