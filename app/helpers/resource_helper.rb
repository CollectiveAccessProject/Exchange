module ResourceHelper

  #
  # Return array of groups owned by the specified user
  # Param is a User instance (typically current_user)
  #
  def groups_for_user(user)
    groups = Group.joins(:user_groups).where({"user_groups.user_id": user.id})

    opts = []
    groups.each do|g|
      opts.push([g.name, g.id])
    end

    opts
  end
end
