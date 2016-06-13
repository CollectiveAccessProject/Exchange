class AddRanksForSorting < ActiveRecord::Migration
  def change
    add_column :media_files, :rank, :integer
  end
end
