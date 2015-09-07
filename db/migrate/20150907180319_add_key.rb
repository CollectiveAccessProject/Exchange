class AddKey < ActiveRecord::Migration
  def change
    remove_index :comments, :name => 'index_comments_on_user_id'
    add_foreign_key :comments, :users

    remove_index :media_files, :name => 'index_media_files_on_resource_id'
    add_foreign_key :media_files, :resources

    remove_index :related_resources, :name => 'index_related_resources_on_from_resource_id_and_to_resource_id'
    add_foreign_key :related_resources, :resources, column: :to_resource_id

    remove_index :resources, :name => 'index_resources_on_forked_from_resource_id'
    add_foreign_key :resources, :resources, column: :forked_from_resource_id

    remove_index :resources, :name => 'index_resources_on_parent_id'
    add_foreign_key :resources, :resources, column: :parent_id

    remove_index :resources, :name => 'index_resources_on_user_id'
    add_foreign_key :resources, :users

    remove_index :tags, :name => 'index_tags_on_user_id'
    add_foreign_key :tags, :users

    remove_index :user_groups, :name => 'index_user_groups_on_group_id'
    add_foreign_key :user_groups, :groups

    remove_index :user_groups, :name => 'index_user_groups_on_user_id'
    add_foreign_key :user_groups, :users
  end
end
