class AddAttachmentMediaToMediaFiles < ActiveRecord::Migration
  def self.up
    change_table :media_files do |t|
      t.attachment :media
      t.string :media_fingerprint
    end
  end

  def self.down
    remove_attachment :media_files, :media
    remove_column :media_files, :media_fingerprint
  end
end
