class ResourceResponse < ActiveRecord::Migration
  def change
    add_column :resources, :in_response_to_resource_id, :integer
  end
end
