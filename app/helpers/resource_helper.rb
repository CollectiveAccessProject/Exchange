module ResourceHelper

  #
  # Return array of groups owned by the specified user
  # Param is a User instance (typically current_user)
  #
  def groups_for_user(user)
    groups = Group.where({user_id: user.id})

    opts = []
    groups.each do|g|
      opts.push([g.name, g.id])
    end

    opts
  end
end
