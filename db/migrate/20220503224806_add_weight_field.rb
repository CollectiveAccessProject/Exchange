class AddWeightField < ActiveRecord::Migration[5.0]
  def change
	  add_column :resources, :sort_weight, :integer
  end
end
