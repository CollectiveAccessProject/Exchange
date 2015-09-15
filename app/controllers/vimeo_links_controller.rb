class VimeoLinksController < ApplicationController
  include SourceableController
  skip_before_action :verify_authenticity_token

  # POST /vimeo_links
  # POST /vimeo_links.json
  def create
    @vimeo_link = VimeoLink.new(vimeo_link_params)

    respond_to do |format|
      if save_and_set_session @vimeo_link
        format.html { redirect_to :back, notice: 'Please fill out the media file information below' }
      else
        format.html { redirect_to :back, notice: 'There was a problem with the VimeoLink' }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def vimeo_link_params
      params.require(:vimeo_link).permit(:original_link)
    end
end
