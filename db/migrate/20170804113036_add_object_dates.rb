class AddObjectDates < ActiveRecord::Migration
  def change
    add_column :resources, :start_date, :decimal, null: true, precision: 40, scale: 20
    add_column :resources, :end_date, :decimal, null: true, precision: 40, scale: 20
  end
end
