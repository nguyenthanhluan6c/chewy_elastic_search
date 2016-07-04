# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
50.times do |n|
  User.create! name: Faker::Name.name, email: "user#{n+1}@gmail.com"
end

100.times do |n|
  Book.create! name: Faker::Book.title,
   desc: Faker::Lorem.paragraph(12, true, 20), user: User.first
end

