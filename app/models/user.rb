class User < ActiveRecord::Base
  rolify
  ratyrate_rater


  after_create :set_default_role

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:shibboleth, :facebook, :google_oauth2]
  #, :confirmable

  validates :name, :presence => true

  has_many :user_groups, :dependent => :destroy
  has_many :groups, :through => :user_groups
  has_many :favorites
  has_many :resources, through: 'resources_users', :dependent => :destroy
  has_many :resources, :dependent => :destroy
  has_many :resources_users, :dependent => :destroy

  def self.from_omniauth(auth)
    begin
		where(provider: auth.provider, uid: auth.uid).first_or_create! do |user|
		  user.email = auth.info.email
		  user.password = Devise.friendly_token[0,20]
		  user.name = auth.info.name
		  user.is_disabled = 0
		end
	rescue
		where(email: auth.info.email).first_or_create! do |user|
		  user.email = auth.info.email
		  user.password = Devise.friendly_token[0,20]
		  user.name = auth.info.name
		  user.is_disabled = 0
		  user.provider = auth.provider
		  user.uid = auth.uid
		end
	end
  end
  
   # ensure user account is active  
  def active_for_authentication?  
    super && (self.is_disabled == 0)
  end 
  
  def set_default_role
    self.add_role(:visitor)
  end
  
  def self.roles
    Rails.application.config.x.user_roles
  end
  

end
