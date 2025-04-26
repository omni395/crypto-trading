# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# --- Admin user and role seed ---
admin_email = 'admin@example.com'
admin_password = '12345678'
admin_user = User.find_or_create_by!(email: admin_email) do |u|
  u.password = admin_password
  u.password_confirmation = admin_password
end

admin_role = Role.find_or_create_by!(name: 'admin')
UserRole.find_or_create_by!(user: admin_user, role: admin_role)
puts "[SEED] Админ-пользователь: #{admin_email} / #{admin_password} (роль admin)"
