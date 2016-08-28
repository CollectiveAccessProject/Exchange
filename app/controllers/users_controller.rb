class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_action :verify_access

  def verify_access
    raise StandardError, "Not allowed" if (!current_user.has_role? :admin)
  end

  def index
    # list all users
    @users = User.all().order("name")
  end

  def edit
    @user = User.find(params[:id])
    @roles_list = [];
    Rails.application.config.x.user_roles.each do |n,r|
      @roles_list.push([n, r])
    end
  end

  def update
    @user = User.find(params[:id])

    password_ok = (params[:user][:new_password].length  == 0)
    if ((params[:user][:new_password].length > 0) && (params[:user][:new_password] == params[:user][:confirm_new_password]))
      @user.password=(params[:user][:new_password])
      password_ok = true
    end

    @user.update(user_params)

    # set roles
    set_roles = !params[:roles] ? [] : params[:roles].collect! do |item|
      item.to_sym   # convert to symbol for comparisons
    end

    Rails.application.config.x.user_roles.each do |n,r|
      next if ((r === :admin) && (@user.id == current_user.id)) # don't allow admin role to be removed for current user (otherwise user config becomes inaccessible)
      (set_roles.include?(r)) ? @user.add_role(r) : @user.remove_role(r)
    end

    respond_to do |format|
      if (@user.save)
        format.html { redirect_to edit_user_path(@user), notice:  (password_ok ? 'User has been updated.' : 'Passwords do not match') }
      else
        format.html { redirect_to edit_user_path(@user), notice:  'Changes could not be saved: ' + @user.errors.full_messages.join("; ") }
      end
    end

  end

  def destroy
    @user = User.find(params[:id])
    name = @user.name

     respond_to do |format|
       if (@user.id != current_user.id)
         @user.destroy
        format.html { redirect_to users_path, notice: 'User ' + name + ' has been removed.'.html_safe }
       else
         format.html { redirect_to users_path, notice: 'You cannot delete yourself.' }
       end
     end

  end

  def user_params
    params.require(:user).permit(
        :name, :email
    )
  end
end