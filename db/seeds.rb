# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require 'faker'

puts "Seeding users..."

40.times do |i|
  fullname = Faker::Name.name
  email = "user#{i + 1}@example.com"
  password = "password123"

  User.create!(
    fullname: fullname,
    email: email,
    password: password,
    password_confirmation: password,
    admin: false 
  )
end

puts "✅ Created 40 users (1 admin, 39 regular users)."