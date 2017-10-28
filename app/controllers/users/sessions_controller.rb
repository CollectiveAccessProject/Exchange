class Users::SessionsController < Devise::SessionsController
# before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
   def create
     super
        # link to role groups
        roles = User.roles
        roles.each do|r|
            g = Group.where(group_code: r[1].to_s).first
            if g
                item = UserGroup.where(group_id: g.id, user_id: @user.id, access_type: 2).first_or_create
            end
        end
     end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
