class Movie < ApplicationRecord
  has_many :post_movies, dependent: :destroy
  has_many :posts, through: :post_movies
end
