class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  #, :confirmable

  validates :first_name, :last_name, :presence => true

  has_many :user_groups
  has_many :groups, :through => :user_groups
end
