# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Clear existing data
Post.destroy_all
Comment.destroy_all

# Create posts
post1 = Post.create!(title: "Amazing Landscape", description: "Lorem ipsum dolor sit amet.")
post2 = Post.create!(title: "City Life", description: "Consectetur adipiscing elit.")
post3 = Post.create!(title: "Mountain Adventure", description: "Sed do eiusmod tempor incididunt.")

# Create comments for posts
post1.comments.create!(content: "This is a great post!")
post1.comments.create!(content: "I love this landscape!")
post2.comments.create!(content: "City life is so vibrant.")
post2.comments.create!(content: "Great insights!")
post3.comments.create!(content: "Mountains are breathtaking.")
post3.comments.create!(content: "I want to visit this place!")
post3.comments.create!(content:"Interesting !!")
