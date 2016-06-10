class YoutubeLinksController < ApplicationController
  include SourceableController
  skip_before_action :verify_authenticity_token

  # POST /youtube_links
  # POST /youtube_links.json
  def create

    begin

      @youtube_link = YoutubeLink.new(youtube_link_params)
      if save_and_set_session @youtube_link
        resp = {:status => "ok", :html => :back}
      end
    rescue StandardError => ex
        puts "Standard Error encountered and rescued"
        resp = {:status => "err", :error => ex.message}
    end

    respond_to do |format|
      format.json {render :json => resp}
    end
  end        

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def youtube_link_params
      params.require(:youtube_link).permit(:key, :original_link)
    end
end
