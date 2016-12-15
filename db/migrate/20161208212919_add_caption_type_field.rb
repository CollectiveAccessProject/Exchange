class AddCaptionTypeField < ActiveRecord::Migration
  def change
  	add_column :resources, :caption_type, :integer, :limit => 4
  end
end
