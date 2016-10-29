class AddUrlToLocalFile < ActiveRecord::Migration
  def change
    add_column :local_files, :url, :string, limit: 255
  end
end
