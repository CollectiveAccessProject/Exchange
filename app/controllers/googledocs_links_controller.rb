class GoogledocsLinksController < ApplicationController
  include SourceableController
  skip_before_action :verify_authenticity_token

  # POST /googledocs_links
  # POST /googledocs_links.json
  def create
    @googledocs_link = GoogledocsLink.new(googledocs_link_params)

    respond_to do |format|
      if save_and_set_session @googledocs_link
        format.html { redirect_to :back, notice: 'Please fill out the media file information below' }
      else
        format.html { redirect_to :back, notice: 'There was a problem with the Google Docs link' }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def googledocs_link_params
      params.require(:googledocs_link).permit(:original_link)
    end
end
