class RenameMediaTitleField < ActiveRecord::Migration
  def change
    rename_column :media_files, :title, :caption
  end
end
