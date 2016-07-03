class ExpandBodyText < ActiveRecord::Migration
  def change
    change_column :resources, :body_text, :text, :limit => 4294967295
  end
end
