class LocalFilesController < ApplicationController
  before_action :set_local_file, only: [:show, :edit, :update, :destroy]

  # GET /local_files
  # GET /local_files.json
  def index
    @local_files = LocalFile.all
  end

  # GET /local_files/1
  # GET /local_files/1.json
  def show
  end

  # GET /local_files/new
  def new
    @local_file = LocalFile.new
  end

  # GET /local_files/1/edit
  def edit
  end

  # POST /local_files
  # POST /local_files.json
  def create
    @local_file = LocalFile.new(local_file_params)

    respond_to do |format|
      if @local_file.save
        format.html { redirect_to @local_file, notice: 'Local file was successfully created.' }
        format.json { render :show, status: :created, location: @local_file }
      else
        format.html { render :new }
        format.json { render json: @local_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /local_files/1
  # PATCH/PUT /local_files/1.json
  def update
    respond_to do |format|
      if @local_file.update(local_file_params)
        format.html { redirect_to @local_file, notice: 'Local file was successfully updated.' }
        format.json { render :show, status: :ok, location: @local_file }
      else
        format.html { render :edit }
        format.json { render json: @local_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /local_files/1
  # DELETE /local_files/1.json
  def destroy
    @local_file.destroy
    respond_to do |format|
      format.html { redirect_to local_files_url, notice: 'Local file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_local_file
      @local_file = LocalFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def local_file_params
      params.require(:local_file).permit(:media, :media_fingerprint)
    end
end
