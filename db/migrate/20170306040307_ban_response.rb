class BanResponse < ActiveRecord::Migration
  def change
    add_column :resources, :response_banned_on, :integer, :null => true
    add_column :resources, :response_ban_reason, :text, :length => 16384
  end
end
