class YoutubeLinksController < ApplicationController
  include SourceableController
  skip_before_action :verify_authenticity_token

  # POST /youtube_links
  # POST /youtube_links.json
  def create
    @youtube_link = YoutubeLink.new(youtube_link_params)

    respond_to do |format|
      if save_and_set_session @youtube_link
        format.html { redirect_to :back, notice: 'Please fill out the media file information below' }
        format.json  { render :json => { id: @youtube_link.id, class: @youtube_link.class.to_s()} }
      else
        format.html { redirect_to :back, notice: 'There was a problem with the Youtube link' }
        format.json  { render :json => { notice: 'There was a problem with the Youtube link' }, status: :unprocessable_entity  }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def youtube_link_params
      params.require(:youtube_link).permit(:key, :original_link)
    end
end
