class ResourcesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_resource, only: [:show, :edit, :update, :destroy, :add_comment, :add_tag, :add_link, :remove_comment, :remove_tag, :remove_link, :save_preferences, :add_related_resource, :remove_related_resource, :add_child_resource, :set_media_order, :set_resource_order, :remove_parent]

  include CommentableController
  include TaggableController

  respond_to :html, :json

  # UI autocomplete on resource title (used by related resources lookup)
  autocomplete :resource, :title, :full => true, :extra_data => [:id]

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

    # Set parent, if set, for display purposes in "new" form
    if ((parent_id = params[:parent_id].to_i) > 0)
      @new_parent_id = parent_id
      @new_parent = Resource.find(parent_id)
    end

    # Set child, if set, for display purposes in "new" form
    @child = nil
    if ((child_id = params[:child_id].to_i) > 0)
      @child  = Resource.find(child_id)
    end

    @resource.resource_type = (params['type'] == 'collection') ? Resource::LEARNING_COLLECTION : Resource::RESOURCE  # preset type
  end

  # GET /resources/1/edit
  def edit
    @media_file = MediaFile.new
    # @resource.settings(:media_formatting).mode = 'foo'
    # @resource.save!
    session[:resource_id] = @resource.id

    # Get list of available collections
    @available_collections = get_available_collections(@resource)
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(resource_params)
    @resource.user = current_user

    params.require(:resource).permit(:parent_id, :child_id)
    parent_id = params[:resource][:parent_id].to_i
    child_id = params[:resource][:child_id].to_i

    respond_to do |format|
      if @resource.save

        if (parent_id > 0)
          # TODO: Verify that current user has privs to do this
          prel = ResourceHierarchy.where(resource_id: parent_id, child_resource_id: @resource.id).first_or_create
        end

        # Set resource under newly created collection or resource
        # TODO: Verify that current user has privs to do this
        if(child_id > 0)
          child = Resource.find(child_id)
         # if (child.user_id == current_user.id)
            prel = ResourceHierarchy.where(resource_id: @resource.id, child_resource_id: child_id).first_or_create
            child.save
          #else

          #end
        end
        session[:mode] = :new;
        format.html { redirect_to edit_resource_path(@resource), notice: ((@resource.resource_type == Resource::RESOURCE) ? "Resource" : "Collection") + ' has been added.'}
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
      if (parent_id = params[:parent_id])
        # TODO: Verify that current user has privs to do this
        if (prel = ResourceHierarchy.where(resource_id: parent_id, child_resource_id: @resource.id).first_or_create)
          format.html { redirect_to edit_resource_path(@resource), notice: ((@resource.resource_type == Resource::RESOURCE) ? "Resource" : "Collection") + ' has been updated.' }
          format.json { render :show, status: :ok, location: @resource }

        else
          format.html { render :edit }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      else
        if @resource.update(resource_params)
          session[:mode] = :update;
          format.html { redirect_to edit_resource_path(@resource), notice: ((@resource.resource_type == Resource::RESOURCE) ? "Resource" : "Collection") + ' has been updated.' }
          format.json { render :show, status: :ok, location: @resource }
        else
          format.html { render :edit }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      end

    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource.destroy
    respond_to do |format|
      format.html { redirect_to resources_url, notice: ((@resource.resource_type == Resource::RESOURCE) ? "Resource" : "Collection") + ' has been removed.' }
      format.json { head :no_content }
    end
  end

  # add new comment
  def add_comment
    # TODO: make sure user is allowed to do this for this resource
    if(super(@resource, true))
      resp = {status: :ok, html: render_to_string("resources/_comments", layout: false)}
    else
      resp = {status: :err, error: flash[:alert]}
    end

    respond_to do |format|
      format.json { render json: resp }
      format.html { redirect_to resource_path(@resource), notice: 'Added comment' }
    end
  end

  def remove_comment
    # TODO: make sure user is allowed to do this for this resource
    t = Comment.where(id: params[:comment_id], commentable_id: @resource.id, commentable_type: :Resource).first
    t.destroy

    resp = {:status => :ok, :html => render_to_string("resources/_comments", layout: false)}

    respond_to do |format|
      format.json { render json: resp }
    end
  end

  # add new tag
  def add_tag
    # TODO: make sure user is allowed to do this for this resource
    if(super(@resource, true))
      resp = {status: :ok, html: render_to_string("resources/_tags", layout: false)}
    else
      resp = {status: :err, error: flash[:alert]}
    end

    respond_to do |format|
      format.json { render json: resp }
      format.html { redirect_to resource_path(@resource), notice: 'Added tag' }
    end
  end

  def remove_tag
    # TODO: make sure user is allowed to do this for this resource
    t = Tag.where(id: params[:tag_id], taggable_id: @resource.id, taggable_type: :Resource).first
    t.destroy

    resp = {:status => :ok, :html => render_to_string("resources/_tags", layout: false)}

    respond_to do |format|
      format.json { render json: resp }
    end
  end

  # add new link
  def add_link
    # TODO: make sure user is allowed to do this for this resource
    params.permit(links: [:url, :caption])
   puts params.inspect
    link = Link.new({url: params[:link][:url], caption: params[:link][:caption], resource_id: @resource.id})

    if(link.save)
      resp = {status: :ok, html: render_to_string("resources/_links", layout: false)}
    else
      resp = {status: :err, error: link.errors.full_messages.join('; ')}
    end

    respond_to do |format|
      format.json { render json: resp }
      format.html { redirect_to resource_path(@resource), notice: 'Added link' }
    end
  end

  def remove_link
    # TODO: make sure user is allowed to do this for this resource
    t = Link.where(id: params[:link_id], resource_id: @resource.id).first
    t.destroy

    resp = {:status => :ok, :html => render_to_string("resources/_links", layout: false)}

    respond_to do |format|
      format.json { render json: resp }
    end
  end

  def remove_parent
    # TODO: make sure user is allowed to do this for this resource
    if (r = ResourceHierarchy.where(:child_resource_id => params[:id], :resource_id => params[:parent_id]).first)
      r.destroy

      @available_collections = get_available_collections(@resource) # regenerate list of available collections to reflect the delete
      resp = {:status => :ok, :html => render_to_string("resources/_collections", layout: false), :header => render_to_string("resources/_resource_parent_display_header", layout: false), :resource_collection_select => render_to_string('resources/_resource_collection_select', layout: false), :collection_count => ResourceHierarchy.where(:child_resource_id => params[:id]).count}
    else
        resp = {status: :err, error: r.errors.full_messages.join('; ')}
    end

    respond_to do |format|
      format.json { render json: resp }
    end
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
      resp = {:status => :ok}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.html
      format.json {render :json => resp }
    end
  end


  def add_child_resource
    begin
      # response

      # TODO: Check if user can relate to target
      add_child_resource_id = params[:add_child_resource_id]

      prel = ResourceHierarchy.where(resource_id: @resource.id, child_resource_id: add_child_resource_id).first_or_create

      resp = {:status => :ok, :html => render_to_string("resources/_resource_list_simple", layout: false)}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json {render :json => resp, status: :ok }
    end
  end

  # add related resource
  def add_related_resource
    begin
      # response

      # TODO: Check if user can relate to target
      to_resource_id = params[:to_resource_id]
      prel = RelatedResource.where(resource_id: @resource.id, to_resource_id: to_resource_id, caption: params[:caption]).first_or_create

      resp = {:status => :ok, :html => render_to_string("resources/_related", layout: false)}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json {render :json => resp, status: :ok }
    end
  end

  # remove related resource
  def remove_related_resource
    begin
      # TODO: Check if user can delete this
      to_resource_id = params[:related]
      RelatedResource.where(resource_id: @resource.id, to_resource_id: to_resource_id).destroy_all
      resp = {:status => :ok, :html => render_to_string("resources/_related", layout: false) }
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json {render :json => resp }
    end
  end

  # set order of media
  def set_media_order
    resp = {status: :ok}

    # TODO: Check if user has access to resource for which media is being reordered

    # get current ranks for media
    current_media = MediaFile.where(resource_id: params[:id]).order(:rank)
    ranks = current_media.pluck(:rank)

    params[:ranks].each do |media_id|
      if (mf = MediaFile.where(resource_id: params[:id], id: media_id).first)
        mf.rank = ranks.shift
        if (!mf.save)
          resp = {:status => :err, :error => mf.errors.full_messages.join('; ')}
          break
        end
      end
    end

    respond_to do |format|
      format.json {render :json => resp }
    end
  end

  # set order of child resources in collection
  def set_resource_order
    resp = {status: :ok}

    # TODO: Check if user has access to collection for which resources are being reordered
    parent_id = params[:id]

    # get current ranks for child resources
    current_child_rels = @resource.resource_hierarchies

    ranks = current_child_rels.pluck(:rank)
    params[:ranks].each do |rel_id|
      if ((rel = ResourceHierarchy.where(id: rel_id).first) && (rel.resource_id.to_i == parent_id.to_i))
        rel.rank = ranks.shift
        if (!rel.save)
          resp = {:status => :err, :error => rel.errors.full_messages.join('; ')}
          break
        end
      else
       # invalid ids
        resp = {:status => :err, :error => "Invalid id"}
        break
      end
    end

    respond_to do |format|
      format.json {render :json => resp }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_resource
    @resource = Resource.find(params[:id])
  end

  # return collections available to the current user
  def get_available_collections(resource)
    ids = resource.parents.pluck(:id)
    ids.push(resource.id)
    return Resource.where("resource_type = ? AND user_id = ? AND id NOT IN (?)", Resource::LEARNING_COLLECTION, current_user.id, ids).order(title: :asc)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:resource).permit(
        :slug, :title, :resource_type, :subtitle, :source_type, :source,
        :copyright_license, :rank, :user_id, :copyright_notes, :access, :body_text
    )
  end
end
