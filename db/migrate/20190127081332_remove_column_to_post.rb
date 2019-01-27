class RemoveColumnToPost < ActiveRecord::Migration[5.2]
  def change
    remove_column :posts, :movie1, :integer
    remove_column :posts, :movie2, :integer
    remove_column :posts, :movie3, :integer
  end
end
