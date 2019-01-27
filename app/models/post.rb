class Post < ApplicationRecord
  has_many :post_movies, dependent: :destroy
  has_many :movies, through: :post_movies
end
