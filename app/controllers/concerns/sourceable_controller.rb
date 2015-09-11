module SourceableController

  def save_and_set_session(instance)
    if instance.save
      session[:sourceable_id] = instance.id
      session[:sourceable_type] = instance.class.to_s
    else
    end
  end

end
