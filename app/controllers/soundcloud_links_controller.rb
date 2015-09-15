class SoundcloudLinksController < ApplicationController
  include SourceableController
  skip_before_action :verify_authenticity_token

  # POST /soundcloud_links
  # POST /soundcloud_links.json
  def create
    @youtube_link = SoundcloudLink.new(soundcloud_link_params)

    respond_to do |format|
      if save_and_set_session @youtube_link
        format.html { redirect_to :back, notice: 'Please fill out the media file information below' }
      else
        format.html { redirect_to :back, notice: 'There was a problem with the Youtube link' }
      end
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def soundcloud_link_params
    params.require(:soundcloud_link).permit(:original_link)
  end
end
