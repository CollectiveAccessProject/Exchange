module TaggableController

  def add_tag(model, dont_redirect)
    tag = Tag.new(tag_params)
    # fill in user and ip
    tag.user = current_user
    tag.ip = request.ip

    begin
      model.tags << tag
    rescue
      flash[:alert] = 'Could not add tag'
    ensure
      if (!dont_redirect)
        redirect_to :action => :show, :id => model.id
      end
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:tag)
  end

end
