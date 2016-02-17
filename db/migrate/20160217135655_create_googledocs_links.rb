class CreateGoogledocsLinks < ActiveRecord::Migration
  def change
    create_table :googledocs_links do |t|
      t.string :original_link

      t.timestamps null: false
    end
  end
end
