class DashboardController < ApplicationController
  before_filter :authenticate_user!

  include CommentableController
  include TaggableController

  # GET /resources
  # GET /resources.json
  def index
    @resources = Resource.all
  end

  # GET /resources/1
  # GET /resources/1.json
  def show
  end

  # GET /resources/new
  def new
    @resource = Resource.new
  end

  # GET /resources/1/edit
  def edit
    @media_file = MediaFile.new

    session[:resource_id] = @resource.id
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(resource_params)
    @resource.user = current_user

    respond_to do |format|
      if @resource.save
        format.html { redirect_to edit_resource_path(@resource), notice: 'Resource was successfully created.' }
        format.json { render :show, status: :created, location: @resource }
      else
        format.html { render :new }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /resources/1
  # PATCH/PUT /resources/1.json
  def update
    respond_to do |format|
      if @resource.update(resource_params)
        format.html { redirect_to edit_resource_path(@resource), notice: 'Resource was successfully updated.' }
        format.json { render :show, status: :ok, location: @resource }
      else
        format.html { render :edit }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource.destroy
    respond_to do |format|
      format.html { redirect_to resources_url, notice: 'Resource was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # add new comment
  def add_new_comment
    add_comment @resource
  end

  # add new tag
  def add_new_tag
    add_tag @resource
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = Resource.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      params.require(:resource).permit(
          :slug, :title, :resource_type, :subtitle, :source_type, :source,
          :copyright_license, :rank, :user_id, :copyright_notes, :access, :body_text
      )
    end

end
