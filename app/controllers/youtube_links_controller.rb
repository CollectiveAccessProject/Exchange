class YoutubeLinksController < SourceableController
  before_action :set_youtube_link, only: [:update, :destroy]

  # POST /youtube_links
  # POST /youtube_links.json
  def create
    @youtube_link = YoutubeLink.new(youtube_link_params)

    respond_to do |format|
      if @youtube_link.save
        session[:sourceable_id] = @youtube_link.id
        session[:sourceable_type] = 'YoutubeLink'

        format.html { redirect_to :back, notice: 'Please fill out the media file information below' }
      else
        format.html { redirect_to :back, notice: 'There was a problem with the Youtube link' }
      end
    end
  end

  # PATCH/PUT /youtube_links/1
  # PATCH/PUT /youtube_links/1.json
  def update
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  # DELETE /youtube_links/1
  # DELETE /youtube_links/1.json
  def destroy
    old_media_file = @youtube_link.media_file

    @youtube_link.media_file = nil
    @youtube_link.destroy
    respond_to do |format|
      format.html { redirect_to edit_media_file_path(old_media_file), notice: 'Youtube link was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_youtube_link
      @youtube_link = YoutubeLink.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def youtube_link_params
      params.require(:youtube_link).permit(:key, :original_link)
    end
end
