class Group < ActiveRecord::Base
  has_many :user_groups,  :dependent => :destroy
  has_many :users, :through => :user_groups
  belongs_to :user

  # slug handling
  include SlugModel
  before_create :set_slug

  def self.group_types
    Rails.application.config.x.group_types
  end
  
  def self.group_membership_types
    Rails.application.config.x.group_membership_types
  end
  
  def can_edit(user)
    return true if self.user_id == user.id
    
    self.user_groups.each do |ug| 
        return true if (ug.user_id == user.id) and (ug.access_type == 3)
    end
    
    false
  end
  
  def self.get_umich_groups_for_user(user)
    # check for directories
    m = /^([A-Za-z0-9\-\_]+)@umich.edu$/.match(user.email)
    if m
        username = m[1]
        ldap = Net::LDAP.new  :host => "ldap.umich.edu",
              :port => 389,
              :encryption => :start_tls,
              #:base => # the base of your AD tree goes here,
              :auth => {
                :method => :simple,
                :username => ENV['LDAP_USERNAME'],
                :password => ENV['LDAP_PASSWORD'],
              }
        begin
            connected = ldap.bind
        rescue Exception => e
            # noop
        end
        if connected
          # authentication succeeded
          ldap.search( :base => "ou=Groups,dc=umich,dc=edu", :filter => "(member=uid=" + username + ",ou=People,dc=umich,dc=edu)" ) do |entry|
            
            groupname = entry[:cn][0]
            if groupname
                #print "\tFound group " + groupname + "\n"
                begin 
                    g = Group.where(name: groupname).first
                    if g 
                        #raise "Group ID IS  " + g.id.to_s
                    else                                
                        g = Group.new({name: groupname, group_type: 2})
                        g.save
                    end

                    # add user to group
                    item = UserGroup.where(group_id: g.id, user_id: user.id, access_type: 1).first_or_create
                rescue Exception => e
                    raise e.message
                end
            end
          end
        end
    end

    # link to role groups
    roles = User.roles
    roles.each do|r|
        g = Group.where(group_code: r[1].to_s).first
        if g
            item = UserGroup.where(group_id: g.id, user_id: user.id, access_type: 1).first_or_create
        end
    end
  end
end
