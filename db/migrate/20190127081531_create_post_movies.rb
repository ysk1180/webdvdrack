class CreatePostMovies < ActiveRecord::Migration[5.2]
  def change
    create_table :post_movies do |t|
      t.integer :post_id
      t.integer :movie_id

      t.timestamps
    end
  end
end
