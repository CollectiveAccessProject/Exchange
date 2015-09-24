class Tag < ActiveRecord::Base

  belongs_to :taggable, polymorphic: true
  belongs_to :user

  before_save :add_ip_to_tag, :fill_sort_field

  def add_ip_to_tag
    unless self.ip?
      self.ip = 'localhost'
    end
  end

  def fill_sort_field
    unless self.tag_sort
      self.tag_sort = self.tag
    end
  end

  def user_name
    begin
      user = User.find(user_id)
      user.name
    rescue
      'anonymous'
    end
  end

end
