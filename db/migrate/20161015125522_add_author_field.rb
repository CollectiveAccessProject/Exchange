class AddAuthorField < ActiveRecord::Migration
  def change
    add_column :resources, :author_name, :string, limit: 255
    add_column :resources, :collection_identifier, :string, limit: 255
  end
end
