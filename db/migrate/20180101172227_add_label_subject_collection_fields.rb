class AddLabelSubjectCollectionFields < ActiveRecord::Migration
  def change
    
    add_column :resources, :collection_area, :string, null: false, default:'', limit: 1024
    add_column :resources, :subject_matter, :text, null: true, limit: 65535
    add_column :resources, :label_copy, :text, null: true, limit: 65535
  end
end
