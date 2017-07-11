class AddArtistNameToResource < ActiveRecord::Migration
  def change
	add_column :resources, :artist, :string, null: false, default:'', limit: 1024
  end
end
