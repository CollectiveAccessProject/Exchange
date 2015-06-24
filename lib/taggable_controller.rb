module TaggableController

  def add_tag(model)
    tag = Tag.new(tag_params)
    # fill in user and ip
    tag.user = current_user
    tag.ip = request.ip

    model.tags << tag
    redirect_to :action => :show, :id => model.id
  end

  private

  def tag_params
    params.require(:tag).permit(:tag)
  end

end
