class FeaturedContentSetItemsController < ApplicationController
  before_filter :authenticate_user!
  before_action :verify_access

  respond_to :html, :json

  def verify_access
    raise StandardError, "Not allowed" if (!current_user.has_role? :admin)
  end

  def update
    @featured_content_set_item = FeaturedContentSetItem.find(params[:id])
    @featured_content_set = FeaturedContentSet.find(@featured_content_set_item.featured_content_set_id)

    respond_to do |format|
      if @featured_content_set_item.update(set_item_params)
        resp = { status: :ok, notice: 'Item was updated', html: render_to_string('featured_content_sets/_item_list' , layout: false, locals: { }) }
        format.json { render :json => resp }
      else
        format.json { render json: @features_content_set_item.errors, status: :unprocessable_entity}
      end
    end

  end

  private
  def set_item_params
    params.require(:featured_content_set_item).permit(
        :title, :subtitle
    )
  end

end
