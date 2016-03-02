class AddIndexingDataToResources < ActiveRecord::Migration
  def change
    # we could use JSON, but that requires MySQL 5.7.8+, which could be a pain to install on CentOS 7
    # whatever -- serializing automatically is easy with ActiveRecord
    add_column :resources, :indexing_data, :text
  end
end
