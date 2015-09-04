class LocalFilesController < ApplicationController
  before_action :set_local_file, only: [:show, :edit, :update, :destroy]

  # GET /local_files
  # GET /local_files.json
  def index
    @sourceables = LocalFile.all
  end

  # GET /local_files/1
  # GET /local_files/1.json
  def show
  end

  # GET /local_files/new
  def new
    @sourceable = LocalFile.new
  end

  # GET /local_files/1/edit
  def edit
  end

  # POST /local_files
  # POST /local_files.json
  def create
    @sourceable = LocalFile.new(local_file_params)
    media_file = MediaFile.find(params[:media_file_id])
    @sourceable.media_file = media_file



    respond_to do |format|
      if @sourceable.save
        format.html { redirect_to edit_media_file_path(@sourceable.media_file), notice: 'Local file was successfully created.' }
        format.json { render :show, status: :created, location: @sourceable }
      else
        format.html { render :new }
        format.json { render json: @sourceable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /local_files/1
  # PATCH/PUT /local_files/1.json
  def update
    respond_to do |format|
      if @sourceable.update(local_file_params)
        format.html { redirect_to edit_media_file_path(@sourceable.media_file), notice: 'Local file was successfully updated.' }
        format.json { render :show, status: :ok, location: @sourceable }
      else
        format.html { render :edit }
        format.json { render json: @sourceable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /local_files/1
  # DELETE /local_files/1.json
  def destroy
    @sourceable.destroy
    respond_to do |format|
      format.html { redirect_to local_files_url, notice: 'Local file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_local_file
      @sourceable = LocalFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def local_file_params
      params.require(:local_file).permit(:file, :file_fingerprint)
    end
end
