class AddResourceAvgRating < ActiveRecord::Migration
  def change
    add_column :resources, :average_rating, :integer, default: 0
  end
end
