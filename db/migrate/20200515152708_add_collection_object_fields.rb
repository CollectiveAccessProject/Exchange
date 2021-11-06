class AddCollectionObjectFields < ActiveRecord::Migration
  def change
  	add_column :resources, :artist_gender, :string, null: false, default:'', limit: 255
  	add_column :resources, :medium_and_support_display, :string, null: false, default:'', limit: 1024
  	add_column :resources, :physical_description, :text, null: true, limit: 65535
  	add_column :resources, :credit_line, :string, null: false, default:'', limit: 1024
  end
end
