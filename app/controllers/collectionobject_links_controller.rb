class CollectionobjectLinksController < ApplicationController
  include SourceableController
  skip_before_action :verify_authenticity_token

  # POST /collectionobject_links
  # POST /collectionobject_links.json
  def create
    @collectionobject_link = CollectionobjectLink.new(collectionobject_link_params)

    respond_to do |format|
      if save_and_set_session @collectionobject_link
        format.html { redirect_to :back, notice: 'Please fill out the media file information below' }
        format.json  { render :json => { id: @collectionobject_link.id, class: @collectionobject_link.class.to_s()} }
      else
        format.html { redirect_to :back, notice: 'There was a problem with the collection object link' }
        format.json  { render :json => { notice: 'There was a problem with the collection object link' }, status: :unprocessable_entity  }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def collectionobject_link_params
      params.require(:collectionobject_link).permit(:host, :key, :original_link)
    end
end