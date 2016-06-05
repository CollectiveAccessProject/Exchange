class CollectiveaccessLinksController < ApplicationController
  include SourceableController
  skip_before_action :verify_authenticity_token

  # POST /collectiveaccess_links
  # POST /collectiveaccess_links.json
  def create
    @collectiveaccess_link = CollectiveaccessLink.new(collectiveaccess_link_params)

    respond_to do |format|
      if save_and_set_session @collectiveaccess_link
        format.html { redirect_to :back, notice: 'Please fill out the media file information below' }
        format.json  { render :json => { id: @collectiveaccess_link.id, class: @collectiveaccess_link.class.to_s()} }
      else
        format.html { redirect_to :back, notice: 'There was a problem with the CollectiveAccess link' }
        format.json  { render :json => { notice: 'There was a problem with the CollectiveAccess link' }, status: :unprocessable_entity  }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def collectiveaccess_link_params
      params.require(:collectiveaccess_link).permit(:host, :key, :original_link)
    end
end