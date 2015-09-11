class LocalFilesController < ApplicationController
  include SourceableController
  skip_before_action :verify_authenticity_token

  # POST /local_files
  # POST /local_files.json
  def create
    @local_file = LocalFile.new(local_file_params)

    respond_to do |format|
      if save_and_set_session @local_file
        format.html { redirect_to :back, notice: 'Please fill out the media file information below' }
      else
        format.html { redirect_to :back, notice: 'There was a problem with the Youtube link' }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def local_file_params
      params.require(:local_file).permit(:file, :file_fingerprint)
    end
end
