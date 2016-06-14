module CommentableController

  def add_comment(model, dont_redirect)
    comment = Comment.new(comment_params)
    # fill in user and ip
    comment.user = current_user
    comment.ip = request.ip

    begin
      res = model.comments << comment
      if comment.errors
        flash[:alert] = comment.errors.full_messages.join('; ')
      end
      res

    rescue
      flash[:alert] = comment.errors.full_messages.join('; ')
    ensure
      if (!dont_redirect)
        redirect_to :action => :show, :id => model.id
      end
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:comment)
  end

end
