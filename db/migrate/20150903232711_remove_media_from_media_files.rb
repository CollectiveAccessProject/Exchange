class RemoveMediaFromMediaFiles < ActiveRecord::Migration
  def change
    remove_attachment :media_files, :media
    remove_column :media_files, :mimetype
    remove_column :media_files, :media_fingerprint

    remove_column :media_files, :source_type
    remove_column :media_files, :source
  end
end
