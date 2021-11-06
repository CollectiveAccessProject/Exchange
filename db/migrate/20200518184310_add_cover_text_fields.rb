class AddCoverTextFields < ActiveRecord::Migration
  def change
  	add_column :resources, :cover_caption, :text, null: true, limit: 65535
  	add_column :resources, :cover_alt_text, :text, null: true, limit: 1024
  end
end
