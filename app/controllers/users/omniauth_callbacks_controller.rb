class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => 'Facebook') if is_navigational_format?
    else
      session['devise.facebook_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end

  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', :kind => 'Google'
      sign_in_and_redirect @user, :event => :authentication
    else
      session['devise.google_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end

  def shibboleth
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
        # check for directories
        m = /^([A-Za-z0-9\-\_]+)@umich.edu$/.match(@user.email)
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
                  ldap.search( :base => "ou=Groups,dc=umich,dc=edu", :filter => "(&(member=uid=" + username + ",ou=People,dc=umich,dc=edu))" ) do |entry|
                    groupname = entry[:cn][0]
                    if groupname
                        begin 
                            g = Group.where(name: groupname).first
                            if g 
                                #raise "Group ID IS  " + g.id.to_s
                            else                                
                                g = Group.new({name: groupname, group_type: 2})
                                g.save
                            end
                            
                            # add user to group
                            item = UserGroup.where(group_id: g.id, user_id: @user.id, access_type: 2).first_or_create
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
                item = UserGroup.where(group_id: g.id, user_id: @user.id, access_type: 2).first_or_create
            end
        end
    
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', :kind => 'Shibboleth'
      sign_in_and_redirect @user, :event => :authentication
    else
      session['devise.shibboleth_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end
end
