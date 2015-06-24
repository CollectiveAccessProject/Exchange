class Comment < ActiveRecord::Base

  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true
  before_save :add_ip_to_comment

  default_scope -> { order('created_at ASC') }

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  # NOTE: Comments belong to a user
  belongs_to :user

  def add_ip_to_comment
    unless self.ip?
      self.ip = 'localhost'
    end
  end

  def user_name
    begin
      user = User.find(user_id)
      user.first_name + ' ' + user.last_name
    rescue
      'anonymous'
    end
  end
end
