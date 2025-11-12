# Run this script with: bin/rails runner create_admin.rb

# Check if admin user already exists
existing_admin = User.find_by(email: 'admin@carnetdevoyage.com')

if existing_admin
  puts "\n⚠️  Admin user already exists. Updating role to admin..."
  existing_admin.update!(role: :admin)
  puts "✅ User updated to admin role!"
else
  # Create new admin user
  user = User.create!(
    username: 'admin',
    email: 'admin@carnetdevoyage.com',
    password: 'password123',
    password_confirmation: 'password123',
    role: :admin  # Using the enum value
  )
  puts "\n✅ Admin user created successfully!"
end

puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
puts "Email:    admin@carnetdevoyage.com"
puts "Password: password123"
puts "Role:     admin"
puts "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
puts "\n📋 To access the admin panel:"
puts "1. Go to http://localhost:3001/users/sign_in"
puts "2. Log in with the credentials above"
puts "3. Navigate to http://localhost:3001/avo\n\n"
