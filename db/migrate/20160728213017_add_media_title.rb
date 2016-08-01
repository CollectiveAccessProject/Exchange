class AddMediaTitle < ActiveRecord::Migration
  def change
    add_column :media_files, :title, :string, limit: 255

    execute "UPDATE media_files SET title = slug"
  end
end