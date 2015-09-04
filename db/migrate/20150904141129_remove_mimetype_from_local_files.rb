class RemoveMimetypeFromLocalFiles < ActiveRecord::Migration
  def change
    # paperclip keeps track of the mimetype in a column
    # called "media_content_type". no need to do that by hand
    remove_column :local_files, :mimetype
  end
end
