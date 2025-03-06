class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many :likes, as: :likeable, dependent: :destroy


  validates :content, presence: true

  def likes_count
    likes.count
  end
end


# class Comment < ApplicationRecord
#   belongs_to :post
# end
