class CreateResourcesUsers < ActiveRecord::Migration
  def change
    create_table :resources_users do |t|
      t.references :resource
      t.references :user
      t.integer :access, limit: 1
    end
  end
end
