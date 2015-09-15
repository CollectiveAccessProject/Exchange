class CreateFlickrLinks < ActiveRecord::Migration
  def change
    create_table :flickr_links do |t|
      t.integer :photo_id, null: false, index: true, limit: 8
      t.string :original_link, null: false

      t.timestamps null: false
    end
  end
end
