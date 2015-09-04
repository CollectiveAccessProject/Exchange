class RenameMediaColumn < ActiveRecord::Migration
  def change
    remove_attachment :local_files, :media
    remove_column :local_files, :media_fingerprint

    add_attachment :local_files, :file
    add_column :local_files, :file_fingerprint, :string
  end
end
