class AddSortableResourceTitle < ActiveRecord::Migration
  def change
    add_column :resources, :title_sort, :text, limit: 65535, null: false
  end
end
