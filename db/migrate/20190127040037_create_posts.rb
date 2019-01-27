class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.integer :movie1
      t.integer :movie2
      t.integer :movie3
      t.string :title
      t.string :name
      t.string :twitter_id
      t.string :h

      t.timestamps
    end
  end
end
