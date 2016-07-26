class DragonflyColumns < ActiveRecord::Migration
  def change
    add_column :media_files, :thumbnail_uid,  :string
  end
end
