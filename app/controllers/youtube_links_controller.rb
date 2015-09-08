class YoutubeLinksController < SourceableController
  before_action :set_youtube_link, only: [:update, :destroy]

  # POST /youtube_links
  # POST /youtube_links.json
  def create
    @youtube_link = YoutubeLink.new(youtube_link_params)
    @youtube_link.media_file = MediaFile.find(params[:media_file_id])

    respond_to do |format|
      if @youtube_link.save
        format.html { redirect_to edit_media_file_path(@youtube_link.media_file), notice: 'Youtube link was successfully created.' }
        #format.json { render :show, status: :created, location: @youtube_link }
      else
        format.html { redirect_to edit_media_file_path(MediaFile.find(params[:media_file_id])) }
        #format.json { render json: @youtube_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /youtube_links/1
  # PATCH/PUT /youtube_links/1.json
  def update
    respond_to do |format|
      if @youtube_link.update(youtube_link_params)
        format.html { redirect_to edit_media_file_path(@youtube_link.media_file), notice: 'Youtube link was successfully updated.' }
        #format.json { render :show, status: :ok, location: @youtube_link }
      else
        format.html { redirect_to edit_media_file_path(@youtube_link.media_file) }
        #format.json { render json: @youtube_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /youtube_links/1
  # DELETE /youtube_links/1.json
  def destroy
    @youtube_link.media_file = nil
    @youtube_link.destroy
    respond_to do |format|
      format.html { redirect_to youtube_links_url, notice: 'Youtube link was successfully destroyed.' }
      format.json { head :no_content }
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
