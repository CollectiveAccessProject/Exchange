class ObjectCreationDate < ActiveRecord::Migration
  def change
  	add_column :resources, :date_display, :string, null: false, limit: 255, default: ''
  end
end
