class AddBodyText < ActiveRecord::Migration
  def change
    add_column :resources, :body_text, :text
  end
end
