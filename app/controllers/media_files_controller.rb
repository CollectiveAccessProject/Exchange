class MediaFilesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_media_file, only: [:show, :edit, :update, :destroy]

  # GET /media_files
  # GET /media_files.json
  def index
    @media_files = MediaFile.all
  end

  # GET /media_files/1
  # GET /media_files/1.json
  def show
  end

  # GET /media_files/new
  def new
    @media_file = MediaFile.new
  end

  # GET /media_files/1/edit
  def edit
  end

  # POST /media_files
  # POST /media_files.json
  def create
    @media_file = MediaFile.new(media_file_params)
    @media_file.set_sourceable_media(params);

    # TODO: does user have access to this resource?
    @media_file.resource_id = params[:media_file][:resource_id]

    @resource = @media_file.resource;

    respond_to do |format|
      if @media_file.save

        format.html do
          if @media_file.resource
            redirect_to edit_resource_path(@media_file.resource), notice: 'Media was added.'
          elsif
            redirect_to @media_file, notice: 'Media was added.'
          end
        end
        format.json { render json: {status: :OK, notice: 'Media was added.', media: @media_file }}
        format.js
      else
        format.json { render json: @media_file.errors.full_messages.join(";"), status: :unprocessable_entity }
        format.html do
          redirect_to edit_resource_path(params[:media_file][:resource_id]), notice: 'Media could not be added: ' + @media_file.errors.full_messages.join(";")
        end
        format.js
      end
    end
  end

  # PATCH/PUT /media_files/1
  # PATCH/PUT /media_files/1.json
  def update
    @resource = @media_file.resource
    respond_to do |format|
      if @media_file.update(media_file_params)
        format.html { redirect_to edit_resource_path(@resource), notice: 'Media was updated.' }
        format.json { render :show, status: :ok, location: @media_file, notice: 'Media was updated' }
      else
        format.html { render :edit }
        format.json { render json: @media_file.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /media_files/1
  # DELETE /media_files/1.json
  def destroy
    @resource = @media_file.resource

    @media_file.destroy
    respond_to do |format|
      format.html { redirect_to edit_resource_path(@resource), notice: 'Media was removed.' }
      format.json { head :no_content }
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_media_file
      @media_file = MediaFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def media_file_params
      params.require(:media_file).permit(
          :slug, :caption, :media, :source_type, :source, :copyright_license, :copyright_notes, :access, :lock_version, :resource_id, :caption_type
      )
    end
end
