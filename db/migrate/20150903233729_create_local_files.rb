class CreateLocalFiles < ActiveRecord::Migration
  def change
    create_table :local_files do |t|
      t.attachment :media
      t.string :media_fingerprint

      t.timestamps null: false
    end

    change_table :media_files do |t|
      t.references :sourceable, polymorphic: true, index: true
    end

  end
end
