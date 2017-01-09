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

  has_many :user_groups
  has_many :groups, :through => :user_groups
  has_many :favorites
  has_many :resources, through: 'resources_users'

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create! do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
    end
  end



  def set_default_role
    self.add_role(:visitor)
  end

end
