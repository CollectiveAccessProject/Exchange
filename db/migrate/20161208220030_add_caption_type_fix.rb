class AddCaptionTypeFix < ActiveRecord::Migration
  def change
  	remove_column :resources, :caption_type
  	add_column :media_files, :caption_type, :integer, :limit => 4
  end
end
