class YoutubeLinksController < ApplicationController
  before_action :set_youtube_link, only: [:show, :edit, :update, :destroy]

  # GET /youtube_links
  # GET /youtube_links.json
  def index
    @media_file = MediaFile.find(params[:media_file_id])
    @sourceables = YoutubeLink.all
  end

  # GET /youtube_links/1
  # GET /youtube_links/1.json
  def show
  end

  # GET /youtube_links/new
  def new
    @sourceable = YoutubeLink.new
  end

  # GET /youtube_links/1/edit
  def edit
  end

  # POST /youtube_links
  # POST /youtube_links.json
  def create
    @sourceable = YoutubeLink.new(youtube_link_params)
    @sourceable.media_file = MediaFile.find(params[:media_file_id])

    respond_to do |format|
      if @sourceable.save
        format.html { redirect_to edit_media_file_path(@sourceable.media_file), notice: 'Youtube link was successfully created.' }
        format.json { render :show, status: :created, location: @sourceable }
      else
        format.html { render :new }
        format.json { render json: @sourceable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /youtube_links/1
  # PATCH/PUT /youtube_links/1.json
  def update
    respond_to do |format|
      if @sourceable.update(youtube_link_params)
        format.html { redirect_to edit_media_file_path(@sourceable.media_file), notice: 'Youtube link was successfully updated.' }
        format.json { render :show, status: :ok, location: @sourceable }
      else
        format.html { render :edit }
        format.json { render json: @sourceable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /youtube_links/1
  # DELETE /youtube_links/1.json
  def destroy
    @sourceable.media_file = nil
    @sourceable.destroy
    respond_to do |format|
      format.html { redirect_to youtube_links_url, notice: 'Youtube link was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_youtube_link
      @sourceable = YoutubeLink.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def youtube_link_params
      params.require(:youtube_link).permit(:key, :original_link)
    end
end
