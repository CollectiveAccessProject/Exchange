class EnlargeCopyrightInfo < ActiveRecord::Migration
  def change
  	change_column :resources, :copyright_notes, :text, :limit => 4294967295
  end
end
