class RolifyResource < ActiveRecord::Migration
  def change
      create_table(:resources_roles, :id => false) do |t|
        t.references :resource
        t.references :role
      end

      add_index(:resources_roles, [ :resource_id, :role_id ])
    end
  end
