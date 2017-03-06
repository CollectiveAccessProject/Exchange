class AddShowLinkToCollectionobject < ActiveRecord::Migration
  def change
    add_column :media_files, :display_collectionobject_link, :integer, :limit => 2
  end
end
