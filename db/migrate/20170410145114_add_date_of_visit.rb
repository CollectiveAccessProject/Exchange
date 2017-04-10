class AddDateOfVisit < ActiveRecord::Migration
  def change
    add_column :resources, :date_of_visit, :timestamp,null: true
  end
end
