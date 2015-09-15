class FlickrLinksController < ApplicationController
  include SourceableController
  skip_before_action :verify_authenticity_token

  # POST /flickr_links
  # POST /flickr_links.json
  def create
    @flickr_link = FlickrLink.new(flickr_link_params)

    respond_to do |format|
      if save_and_set_session @flickr_link
        format.html { redirect_to :back, notice: 'Please fill out the media file information below' }
      else
        format.html { redirect_to :back, notice: 'There was a problem with the FlickrLink' }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def flickr_link_params
      params.require(:flickr_link).permit(:original_link)
    end
end
