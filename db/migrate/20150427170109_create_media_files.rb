class CreateMediaFiles < ActiveRecord::Migration
  def change
    create_table :media_files do |t|
      t.string :slug, null: false, index: true, default: ''
      t.references :resource, null: true

      t.text :title, null: false, limit: 65535

      t.string :source_type, null:false, limit: 10
      t.string :source

      t.text :media, null: false
      t.string :md5, limit: 32, null: true
      t.string :mimetype, limit: 100, null: true

      t.integer :copyright_license, null: false, default: 0, limit: 1
      t.string :copyright_notes, null: false
      t.integer :access, null: false, default: 0, limit: 1

      t.integer :lock_version, null: false, default: 0

      t.timestamps null: false
    end
  end
end
