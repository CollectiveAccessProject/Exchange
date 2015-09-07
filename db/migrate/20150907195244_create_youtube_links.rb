class CreateYoutubeLinks < ActiveRecord::Migration
  def change
    create_table :youtube_links do |t|
      t.string :key, null: false, limit: 16, index: true
      t.string :original_link, null: false

      t.timestamps null: false
    end
  end
end
