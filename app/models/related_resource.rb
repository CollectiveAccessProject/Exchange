class RelatedResource < ActiveRecord::Base
  belongs_to :resource, class_name: 'Resource', foreign_key: 'resource_id', :dependent => :destroy
  belongs_to :related, class_name: 'Resource', foreign_key: 'to_resource_id', :dependent => :destroy

  after_create :set_rank

  def set_rank
    self.rank = self.id
    self.save
  end
end
