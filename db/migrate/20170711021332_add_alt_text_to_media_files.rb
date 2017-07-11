class AddAltTextToMediaFiles < ActiveRecord::Migration
  def change
	add_column :media_files, :alt_text, :string, null: false, limit: 4096, default: ''
  end
end
