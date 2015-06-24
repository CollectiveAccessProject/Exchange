module CommentableController

  def add_comment(model)
    comment = Comment.new(comment_params)
    # fill in user and ip
    comment.user = current_user
    comment.ip = request.ip

    model.comments << comment
    redirect_to :action => :show, :id => model.id
  end

  private

  def comment_params
    params.require(:comment).permit(:comment)
  end

end
