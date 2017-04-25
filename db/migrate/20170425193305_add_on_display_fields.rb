class AddOnDisplayFields < ActiveRecord::Migration
  def change
    add_column :resources, :on_display, :boolean,null: true, default: false
    add_column :resources, :location, :string, null: true, default:""
  end
end
