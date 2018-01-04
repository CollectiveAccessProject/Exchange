class AddKeywordsAndGalleryUrl < ActiveRecord::Migration
  def change
    add_column :resources, :keywords, :text, null: true, limit: 65535
    add_column :resources, :gallery_url, :string, null: false, limit: 1024
  end
end
