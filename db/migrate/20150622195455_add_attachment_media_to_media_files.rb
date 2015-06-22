class AddAttachmentMediaToMediaFiles < ActiveRecord::Migration
  def self.up
    change_table :media_files do |t|
      t.attachment :media
    end
  end

  def self.down
    remove_attachment :media_files, :media
  end
end
