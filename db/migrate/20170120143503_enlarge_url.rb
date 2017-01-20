class EnlargeUrl < ActiveRecord::Migration
  def change
    change_column :links, :url, :string, limit: 1024
  end
end
