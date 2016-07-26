class FavoritesController < ApplicationController
  before_filter :authenticate_user!


  respond_to :json

  def add
    params.permit(:id)  # is is resource_id to favorite

    # TODO verify user has access to resource or resource is public
    f = Favorite.new(resource_id: params[:id], user_id: current_user.id)

    respond_to do |format|
      if (f.save)

        format.json { render json: { status: :ok, message: "Added to favorites", favorite_id: f.id, html: render_to_string(template: "favorites/_favorite_control.html.erb", layout: false, locals: {resource: Resource.find(params[:id])}) }}
      else
        format.json {render json: { status: :err, message: "Could not add favorite: " + f.errors.full_messages.join('; ')}}
      end
    end
  end

  def remove
    params.permit(:id)  # is is favorites id to remove

    f = Favorite.where(id: params[:id], user_id: current_user.id).first

    respond_to do |format|
      if (f)
        resource_id = f.resource_id
        if (f.destroy)
          format.json { render json: { status: :ok, message: "Removed favorite", html: render_to_string(template: "favorites/_favorite_control.html.erb", layout: false, locals: {resource: Resource.find(resource_id)})}}
        else
          format.json {render json: { status: :ok, message: "Could not remove favorite: " + f.errors.full_messages.join('; ')}}
        end
      else
        format.json {render json: { status: :err, message: "Favorite does not exist" }}
      end
    end
  end
end
