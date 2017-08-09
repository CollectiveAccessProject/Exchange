class AddMoreObjectFields < ActiveRecord::Migration
  def change
    add_column :resources, :classification, :string, null: false, default:'', limit: 255
    add_column :resources, :additional_classification, :string, null: false, default:'', limit: 255
    add_column :resources, :medium, :string, null: false, default:'', limit: 255
    add_column :resources, :support, :string, null: false, default:'', limit: 255
    add_column :resources, :style, :string, null: false, default:'', limit: 255
    add_column :resources, :artist_nationality, :string, null: false, default:'', limit: 255
  end
end
