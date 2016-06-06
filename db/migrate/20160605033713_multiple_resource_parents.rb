class MultipleResourceParents < ActiveRecord::Migration
  def change
      remove_foreign_key :resources, :parent
      remove_column :resources, :parent_id
  end
end
