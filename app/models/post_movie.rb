class PostMovie < ApplicationRecord
  belongs_to :post
  belongs_to :movie
end
