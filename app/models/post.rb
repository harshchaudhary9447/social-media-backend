class Post < ApplicationRecord
    belongs_to :user
    has_many :comments, dependent: :destroy
    has_many :likes, as: :likeable, dependent: :destroy


    validates :title, presence: true
    validates :description, presence: true

    def likes_count
      likes.count
    end
end
