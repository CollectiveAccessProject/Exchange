class LogUserOnKeywordLinks < ActiveRecord::Migration
  def change
    add_reference :resources_vocabulary_terms, :user, index: true
    add_column :resources_vocabulary_terms, :ip, :string, limit: 15, index:true, null: false
  end
end
