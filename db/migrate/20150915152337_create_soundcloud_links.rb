class CreateSoundcloudLinks < ActiveRecord::Migration
  def change
    create_table :soundcloud_links do |t|
      t.string :original_link, null: false, index: true

      t.timestamps null: false
    end
  end
end
