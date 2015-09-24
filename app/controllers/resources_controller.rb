class ResourcesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_resource, only: [:show, :edit, :update, :destroy, :add_new_comment, :add_new_tag, :save_preferences]

  include CommentableController
  include TaggableController

  respond_to :html, :json

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
   # @resource.settings(:media_formatting).mode = 'foo'
   # @resource.save!
    session[:resource_id] = @resource.id
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(resource_params)
    @resource.user = current_user

    respond_to do |format|
      if @resource.save
        format.html { redirect_to edit_resource_path(@resource), notice: 'Resource has been added.' }
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
        format.html { redirect_to edit_resource_path(@resource), notice: 'Resource has been updated.' }
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
      format.html { redirect_to resources_url, notice: 'Resource has been removed.' }
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

  # save preferences
  def save_preferences
    params.permit(:media_formatting_mode, :text_placement_placement, :text_formatting_show_all, :text_formatting_collapse, :user_interaction_allow_comments, :user_interaction_allow_tags, :user_interaction_allow_responses, :user_interaction_display_responses_on_separate_page)

    resp = nil

    begin
      # Save individual setting values
      @resource.settings(:media_formatting).mode = params[:media_formatting_mode].to_sym;
      @resource.settings(:text_placement).placement = params[:text_placement_placement].to_sym;

      @resource.settings(:text_formatting).show_all = (params[:text_formatting_show_all] == "show_all") ? 1 : 0;
      @resource.settings(:text_formatting).collapse = (params[:text_formatting_collapse] == "collapse") ? 1 : 0;

      @resource.settings(:user_interaction).allow_comments = (params[:user_interaction_allow_comments] == "allow_comments") ? 1 : 0;
      @resource.settings(:user_interaction).allow_tags = (params[:user_interaction_allow_tags] == "allow_tags") ? 1 : 0;

      @resource.settings(:user_interaction).allow_responses = (params[:user_interaction_allow_responses] == "allow_responses") ? 1 : 0;
      @resource.settings(:user_interaction).display_responses_on_separate_page = (params[:user_interaction_display_responses_on_separate_page] == "display_responses_on_separate_page") ? 1 : 0;

      @resource.save;

      # response
      resp = {:status => "ok"}
    rescue StandardError => ex
      resp = {:status => "err", :error => ex.message}
    end

    respond_to do |format|
      format.html
      format.json {render :json => resp }
    end
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
