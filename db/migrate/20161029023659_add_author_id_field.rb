class AddAuthorIdField < ActiveRecord::Migration
  def change
    add_column :resources, :author_id, :integer
  end
end
