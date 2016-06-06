class CreateCollectiveaccessLinks < ActiveRecord::Migration
  def change
    create_table :collectiveaccess_links do |t|
      t.string :host, null: false, limit: 255, index: true
      t.string :key, null: false, limit: 50, index: true
      t.string :base_url, null: false, limit: 255, index: true
      t.string :original_link, null: false

      t.timestamps null: false
    end
  end
end
