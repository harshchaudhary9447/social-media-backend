class AddVisibilityToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :visibility, :string
  end
end
