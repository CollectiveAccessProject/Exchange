class AddLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.references :resource, null: false

      t.text :caption, null: false, limit: 65535
      t.string :url, null: false, limit: 255

      t.timestamps null: false
    end

    add_index :links, [:resource_id, :url], :unique => true, name: 'unique_link_per_resource', length: {url: 255}
  end
end
