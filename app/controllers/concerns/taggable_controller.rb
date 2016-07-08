module TaggableController
  def add_tag(model, dont_redirect)
    tag_params.each do |t|
      if (t.length == 0)
        flash[:alert] = "No tag specified"
        return false
      end
      tag = Tag.new({tag: t })
      # fill in user and ip
      tag.user = current_user
      tag.ip = request.ip

      begin
        res = model.tags << tag

        if tag.errors
          flash[:alert] = tag.errors.full_messages.join('; ')
        end
        res
      rescue
        flash[:alert] = tag.errors.full_messages.join('; ')
          return false
      ensure
        if (!dont_redirect)
          redirect_to :action => :show, :id => model.id
        end
      end
    end
    return true
  end

  private

  def tag_params
    tp = params.require(:tag).permit(:tag)
    tag_str = tp[:tag]
    tag_str.split(/[ ]*,[ ]*/)
  end

end
