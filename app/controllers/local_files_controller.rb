class LocalFilesController < SourceableController
  before_action :set_local_file, only: [:update, :destroy]

  # POST /local_files
  # POST /local_files.json
  def create
    @local_file = LocalFile.new(local_file_params)
    @local_file.media_file = MediaFile.find(params[:media_file_id])

    respond_to do |format|
      if @local_file.save
        format.html { redirect_to edit_media_file_path(@local_file.media_file), notice: 'Local file was successfully created.' }
      else
        format.html { redirect_to edit_media_file_path(MediaFile.find(params[:media_file_id])) }
      end
    end
  end

  # PATCH/PUT /local_files/1
  # PATCH/PUT /local_files/1.json
  def update
    respond_to do |format|
      if @local_file.update(local_file_params)
        format.html { redirect_to edit_media_file_path(@local_file.media_file), notice: 'Local file was successfully updated.' }
      else
        format.html { redirect_to edit_media_file_path(@local_file.media_file) }
      end
    end
  end

  # DELETE /local_files/1
  # DELETE /local_files/1.json
  def destroy
    old_media_file = @local_file.media_file
    @local_file.media_file = nil
    @local_file.destroy
    respond_to do |format|
      format.html { redirect_to edit_media_file_path(old_media_file), notice: 'Local file was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_local_file
      @local_file = LocalFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def local_file_params
      params.require(:local_file).permit(:file, :file_fingerprint)
    end
end
