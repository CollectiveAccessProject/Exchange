class ObjectCreationDate < ActiveRecord::Migration[5.0]
  def change
  	add_column :resources, :date_display, :string, null: false, limit: 255, default: ''
  end
end
