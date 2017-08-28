class ResourcesController < ApplicationController
  before_filter :authenticate_user!, :except => [:view, :show, :autocomplete_current_location, :load_media_modal, :load_fullscreen_slideshow, :load_thumbnails]
  before_action :set_resource, only: [:show, :edit, :view, :update, :fork, :toggle_access, :destroy, :add_comment, :add_tag, :add_term, :add_link, :remove_comment, :remove_tag, :remove_term, :remove_link, :save_preferences, :add_related_resource, :remove_related_resource, :add_child_resource, :add_child_resources, :set_media_order, :set_resource_order, :remove_parent, :add_user_access, :remove_user_access, :add_group_access, :remove_group_access, :set_response_info, :get_media_list, :load_thumbnails]

  include CommentableController
  include TaggableController

  respond_to :html, :json, :js

  # UI autocomplete on resource title (used by related resources lookup)
  autocomplete :resource, :title, :full => true, :extra_data => [:id, :collection_identifier, :resource_type, :indexing_data], :display_value => :get_autocomplete_label

  # UI autocomplete on user name/email (used by user lookup)
  autocomplete :user, :name, :full => true, :extra_data => [:id]

  # UI autocomplete on vocabulary terms
  autocomplete :vocabulary_term, :term, :full => true, :extra_data => [:id]

  # Filter on type when mode param is set
  def get_autocomplete_items(parameters)
    params.permit(:mode)
    if (!params[:mode].nil?)
      super(parameters).where(:resource_type => params[:mode])
    else
      super(parameters)
    end
  end

  # Override user name/email autocomplete to match on both name and email (sigh)
  def autocomplete_user_name
    term = params[:term]
    u = User.where(
        'LOWER(users.name) LIKE ? OR LOWER(users.email) LIKE ?',
        "%#{term}%", "%#{term}%"
    ).order(:id).all
    render :json => u.map { |user| {:id => user.id, :label => user.name + " (" + user.email + ")", :value => user.name + " (" + user.email + ")"} }
  end

  # Override resource title autocompleter
  def autocomplete_resource_title
    term = params[:term]
    u = Resource.where(
        'LOWER(resources.title) LIKE ? OR LOWER(resources.collection_identifier) LIKE ? OR LOWER(resources.artist) LIKE ?',
        "%#{term}%", "#{term}%", "%#{term}%"
    ).order(:id).all
    render :json => u.map { |r| {:id => r.id, :label => (l = r.get_autocomplete_label), :value => l, :indexing_data => r.indexing_data} }
  end

  def autocomplete_vocabulary_term_term
    term = params[:term]
    u = VocabularyTerm.joins("LEFT JOIN vocabulary_term_synonyms ON vocabulary_terms.id = vocabulary_term_synonyms.vocabulary_term_id").where(
        'LOWER(vocabulary_terms.term) LIKE ? OR LOWER(vocabulary_term_synonyms.synonym) LIKE ?',
        "%#{term}%", "#{term}%"
    ).order(:id).distinct
    render :json => u.map { |r| {:id => r.id, :label => (l = r.term), :value => l} }
  end

  #
  def autocomplete_author
    term = params[:term]
    u = User.joins("INNER JOIN resources ON resources.user_id = users.id OR resources.author_id = users.id").where(
        'LOWER(users.name) LIKE ?',
        "%#{term}%"
    ).order(:id).distinct
    render :json => u.map { |user| {:id => user.id, :label => user.name, :value => user.name} }
  end

  #
  def autocomplete_current_location
    term = params[:term]
     u = Resource.where(
        'LOWER(resources.location) LIKE ?',
        "%#{term}%"
    ).order(:location).group(:location)
    render :json => u.map { |r| {:id => r.id, :label => r.location, :value => r.location} }
  end

  # GET /resources
  # GET /resources.json
  def index
    redirect_to(dashboard_url)
  end

  # GET /resources/1
  # GET /resources/1.json
  def show

    if(!@resource.can(:view, current_user))
      redirect_to root_path, notice: "That resource is not accessible"
      return
    end

    @available_collections = get_available_collections(@resource)
    @available_collections_and_resources = get_available_collections_and_resources(@resource)

    if(@resource.is_collection)
      # session for last collection so can attribute parent when resource has multiple parent collections
      session[:last_collection] = @resource.id
    end

    @search_next_resource_id = @search_previous_resource_id = nil

    # next/previous ids from current search
    ct = @resource.resource_type_as_sym.to_s
    if (session[:last_search_results] && (session[:last_search_results].length) && (session[:last_search_results][ct]) && (i = session[:last_search_results][ct].index(@resource.id)))
      @search_next_resource_id = session[:last_search_results][ct][i+1] if (i<(session[:last_search_results][ct].length - 1))
      @search_previous_resource_id = session[:last_search_results][ct][i-1] if (i > 0)
    end

  end

  # Handle public viewing of resources
  def view
    if(!@resource.can(:view, current_user))
      redirect_to root_path, notice: "That resource is not accessible"
      return
    end

    render :show
  end

  # GET /resources/new
  def new
    @resource = Resource.new

    # Set parent, if set, for display purposes in "new" form
    if ((parent_id = params[:parent_id].to_i) > 0)
      @new_parent_id = parent_id
      @new_parent = Resource.find(parent_id)
    end

    # Set response pointer
    if ((in_response_to_resource_id = params[:in_response_to_resource_id].to_i) > 0)
      parent_resource = Resource.find(in_response_to_resource_id)
      if (!parent_resource.can(:view, current_user))
        redirect_to root_path, notice: "You cannot add a response to that resource"
        return
      end
      @resource.in_response_to_resource_id = in_response_to_resource_id
    end

    # Set child, if set, for display purposes in "new" form
    @child = nil
    if ((child_id = params[:child_id].to_i) > 0)
      @child = Resource.find(child_id)
    end

    # preset type
    case params['type']
      when 'collection'
        @resource.resource_type = Resource::LEARNING_COLLECTION
      when 'crcset'
        @resource.resource_type = Resource::CRCSET
      else
        @resource.resource_type = Resource::RESOURCE
    end
  end

  # GET /resources/1/edit
  def edit
    if(!@resource.can(:edit, current_user))
      redirect_to root_path, notice: "That resource is not accessible"
      return
    end
    @media_file = MediaFile.new
    # @resource.settings(:media_formatting).mode = 'foo'
    # @resource.save!
    session[:resource_id] = @resource.id

    # Get list of available collections
    @available_collections = get_available_collections(@resource)

  end

  def set_roles
    r = []
    Rails.application.config.x.user_roles.each do |k,v|
      next if ((v == :admin))

      if (params[:roles] && (params[:roles].include? v.to_s))
        @resource.add_role(v)
        r.push(v.to_s)
      else
        @resource.remove_role(v)
      end
    end

    # set role text field to force ElasticSearch indexing (maybe we can get rid of this?)
    #@resource.role = r.join("; ")
    #@resource.save

  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(resource_params)
    @resource.user = current_user

    params.require(:resource).permit(:parent_id, :child_id)
    parent_id = params[:resource][:parent_id].to_i
    child_id = params[:resource][:child_id].to_i

    if (@resource.is_crc_set)
      if(!current_user.has_role?(:staff))
        redirect_to root_path, notice: "You do not have access to create this type of resource"
      end
      @resource.date_of_visit = DateTime.new(params[:resource]['date_of_visit(1i)'].to_i, params[:resource]['date_of_visit(2i)'].to_i, params[:resource]['date_of_visit(3i)'].to_i, params[:resource]['date_of_visit(4i)'].to_i, params[:resource]['date_of_visit(5i)'].to_i, 0)
    end

    [:copyright_notes].each do|f|
      @resource.send(:"#{f}=", "")
    end

    @resource.copyright_license = 0 if (!params[:resource][:copyright_license])

    respond_to do |format|
      if @resource.save
        set_roles

        if (parent_id > 0)
          parent_res = Resource.find(parent_id)
	  if(!parent_res.can(:edit, current_user))
	    redirect_to root_path notice: 'You do not have permission to add materials to this Resource'
	    return  
	  end
          prel = ResourceHierarchy.where(resource_id: parent_id, child_resource_id: @resource.id).first_or_create
        end

        # Set response pointer
        if ((in_response_to_resource_id = params[:in_response_to_resource_id].to_i) > 0)
          parent_resource = Resource.find(in_response_to_resource_id)
          if (!parent_resource.can(:view, current_user))
            redirect_to root_path, notice: "You cannot add a response to that resource"
            return
          end
          @resource.in_response_to_resource_id = in_response_to_resource_id
        end

        # Set resource under newly created collection or resource
        if (child_id > 0)
          child = Resource.find(child_id)
	  if(!child.can(:view, current_user))
	    redirect_to root_path, notice: 'You do not have editing privliges for that child resource'
	    return
	  end
          prel = ResourceHierarchy.where(resource_id: @resource.id, child_resource_id: child_id).first_or_create
          child.save
        end

        session[:mode] = :new;

        @resource.index_for_search

        if (@resource && @resource.in_response_to_resource_id && (@resource.in_response_to_resource_id > 0))
          parent_resource = Resource.find(@resource.in_response_to_resource_id)
          if (!parent_resource.can(:view, current_user))
            redirect_to root_path, notice: "You cannot add a response to that resource"
            return
          end
          # Add resource as child of what we're responding to (not sure why UMMA wants this?)
          rh = ResourceHierarchy.where(resource_id: @resource.in_response_to_resource_id, child_resource_id: @resource.id).first_or_create
          rh.save
        end

        format.html { redirect_to edit_resource_path(@resource), notice: @resource.resource_type_for_display + ' has been added.' }
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


    [:subtitle, :copyright_notes].each do|f|
      @resource.send(:"#{f}=", "")
    end

    if (@resource.is_crc_set)
      @resource.date_of_visit = DateTime.new(params[:resource]['date_of_visit(1i)'].to_i,params[:resource]['date_of_visit(2i)'].to_i,params[:resource]['date_of_visit(3i)'].to_i,params[:resource]['date_of_visit(4i)'].to_i,params[:resource]['date_of_visit(5i)'].to_i, 0)
    end

    respond_to do |format|
      if (parent_id = params[:parent_id])
        if ((in_response_to_resource_id = params[:in_response_to_resource_id].to_i) > 0)
            parent_resource = Resource.find(in_response_to_resource_id)
            if (!parent_resource.can(:edit, current_user))
              redirect_to root_path, notice: "You do not have editing privleges on that parent resource"
              return
            end
        end
        if (prel = ResourceHierarchy.where(resource_id: parent_id, child_resource_id: @resource.id).first_or_create)

          format.html { redirect_to edit_resource_path(@resource), notice: @resource.resource_type_for_display + ' has been updated.' }
          format.json { render :show, status: :ok, location: @resource }

        else
          format.html { render :edit }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      else
        if @resource.update(resource_params)
          set_roles
          session[:mode] = :update;

          @resource.index_for_search

          format.html { redirect_to edit_resource_path(@resource), notice: @resource.resource_type_for_display + ' has been updated.' }
          format.json { render :show, status: :ok, location: @resource }
        else
          format.html { render :edit }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      end

    end
  end

  # POST /resources/fork/1
  def fork
    if(!@resource.can(:view, current_user) or @resource.is_collection_object or @resource.copyright_license == 0)
      redirect_to root_path, notice: "That resource cannot be copied"
      return
    end
    r = @resource.dup
    r.forked_from_resource_id = @resource.id
    r.user_id = current_user.id
    if (r.save)
      # dupe media
      @resource.media_files.each do |m|
        next if (!m.sourceable)
        mf = m.dup
        mf.resource_id = r.id
        
        sf = m.sourceable.dup
        if (sf.save)

          mf.set_slug
          mf.sourceable_id = sf.id

          mf.save
        end
      end
      redirect_to edit_resource_path(r), notice: "Forked resource"
    else
      redirect_to dashboard_path, notice: "Could not fork resource"
    end
  end

  def toggle_access
    # can user edit this?
    if (!@resource.can(:edit, current_user))
      redirect_to root_path notice: 'You do not have edit access to that Resource'
      return
    end
    if (@resource.access == 0)
      @resource.access = 1
      @resource.save
      msg = "Published " + @resource.resource_type_for_display
    else
      @resource.access = 0
      @resource.save
      msg = "Unpublished " + @resource.resource_type_for_display
    end
    #@resource.update_search_index
    redirect_to dashboard_path, notice: msg
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    if (@resource.forked_resources.count > 0)
      respond_to do |format|
        format.json { render json: {status: :err, error: 'Cannot delete resource because forks exists'} }
        format.html { redirect_to resource_path(@resource), notice: 'Cannot delete resource because forks exists' }
      end
      return
    end
    @resource.destroy
    respond_to do |format|
      format.html { redirect_to resources_url, notice: @resource.resource_type_for_display + ' has been removed.' }
      format.json { head :no_content }
    end
  end

  # add new comment
  def add_comment
    if(!@resource.can(:view, current_user) || @resource.settings(:user_interaction).allow_comments != 1)
      redirect_to root_path notice: 'You do not have permission to add a comment to that resource'
      return
    end
    if (super(@resource, true))
      resp = {status: :ok, html: render_to_string("resources/_comments", layout: false)}
    else
      resp = {status: :err, error: flash[:alert]}
    end

    @resource.update_search_index
    respond_to do |format|
      format.json { render json: resp }
      format.html { redirect_to resource_path(@resource), notice: 'Added comment' }
    end
  end

  def remove_comment
    if(!@resource.can(:edit, current_user))
      redirect_to root_path notice: 'You do not have the ability to remove comments from this resource'
      return
    end
    t = Comment.where(id: params[:comment_id], commentable_id: @resource.id, commentable_type: :Resource).first
    t.destroy

    @resource.update_search_index
    resp = {:status => :ok, :html => render_to_string("resources/_comments", layout: false)}

    respond_to do |format|
      format.json { render json: resp }
    end
  end

  # Send Report Email
  def send_report
    options = {}
    if params[:email]
      email = params[:email]
    else
      r_user_name = params[:r_user_name]
      r_user_email = params[:r_user_email]
    end
    report = params[:report]
    r_title = params[:r_title]
    r_id = params[:r_id]
    ReportMailer.report_email(report, r_title, r_id, { email: email, r_user_name: r_user_name, r_user_email: r_user_email }).deliver_now
    flash[:notice] = 'A Report has been filed on this Resorce'
    redirect_to :back
  end

  # add new tag
  def add_tag
    if(!@resource.can(:view, current_user) || @resource.settings(:user_interaction).allow_tags != 1)
      redirect_to root_path notice: 'You do not have the ability to add tags to this resource'
      return
    end
    if (super(@resource, true))
      @resource.update_search_index
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
    if(!@resource.can(:edit, current_user))
      redirect_to root_path notice: 'You do not have the ability to remove tags from this resource'
      return
    end
    if(t = Tag.where(id: params[:tag_id], taggable_id: @resource.id, taggable_type: :Resource).first)
      t.destroy

      @resource.update_search_index
      resp = {:status => :ok, :html => render_to_string("resources/_tags", layout: false)}
    else
      resp = {status: :err, error: "Invalid parameters"}
    end

    respond_to do |format|
      format.json { render json: resp }
    end
  end

  # add new vocabulary term
  def add_term
    if(!@resource.can(:view, current_user) || @resource.settings(:user_interaction).allow_tags != 1)
      redirect_to root_path notice: 'You do not have the ability to add vocabulary terms to this resource'
      return
    end

    if (ResourcesVocabularyTerm.where(vocabulary_term_id: params[:term_id], resource_id: @resource.id, user_id: current_user.id, ip: request.remote_ip).first_or_create)
      @resource.update_search_index
      resp = {status: :ok, html: render_to_string("resources/_tags", layout: false)}
    else
      resp = {status: :err, error: flash[:alert]}
    end

    respond_to do |format|
      format.json { render json: resp }
      format.html { redirect_to resource_path(@resource), notice: 'Added term' }
    end
  end

  def remove_term
    # TODO: make sure user is allowed to do this for this resource
    if (t = ResourcesVocabularyTerm.where(vocabulary_term_id: params[:term_id], resource_id: @resource.id).first)
      t.destroy
      @resource.update_search_index
      resp = {:status => :ok, :html => render_to_string("resources/_tags", layout: false)}
    else
      resp = {status: :err, error: "Invalid parameters"}
    end

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

    if (link.save)
      @resource.update_search_index
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

    @resource.update_search_index
    resp = {:status => :ok, :html => render_to_string("resources/_links", layout: false)}

    respond_to do |format|
      format.json { render json: resp }
    end
  end

  def edit_link
    # TODO: make sure user is allowed to do this for this resource
    if (l = Link.where(id: params[:link_id]).first)
      l.url = params[:url]
      if (l.save)
        resp = {status: :ok}
      else
        resp = {status: :error, msg: r.errors.full_messages.join('; ')}
      end

    else
      resp = {status: :error, msg: "No link found"}
    end

    respond_to do |format|
      format.json { render json: resp }
    end
  end

  def edit_link_caption
    # TODO: make sure user is allowed to do this for this resource
    if (l = Link.where(id: params[:link_id]).first)
      l.caption = params[:caption]
      if (l.save)
        resp = {status: :ok}
      else
        resp = {status: :error, msg: r.errors.full_messages.join('; ')}
      end

    else
      resp = {status: :error, msg: "No link found"}
    end

    respond_to do |format|
      format.json { render json: resp }
    end
  end

  def remove_parent
    # TODO: make sure user is allowed to do this for this resource
    if (r = ResourceHierarchy.where(:child_resource_id => params[:id], :resource_id => params[:parent_id]).first)
      if (r.destroy)
        #@resource.update_search_index
        @available_collections = get_available_collections(@resource) # regenerate list of available collections to reflect the delete
        resp = {:status => :ok, :html => render_to_string("resources/_collections", layout: false), :header => render_to_string("resources/_resource_parent_display_header", layout: false), :resource_collection_select => render_to_string('resources/_resource_collection_select', layout: false), :collection_count => ResourceHierarchy.where(:child_resource_id => params[:id]).count}
      else
        resp = {status: :err, error: r.errors.full_messages.join('; ')}
      end

    else
      resp = {status: :err, error: "No relationship found"}
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
      @resource.settings(:media_formatting).mode = params[:media_formatting_mode].to_sym if(!params[:media_formatting_mode].nil?);
      @resource.settings(:text_placement).placement = params[:text_placement_placement].to_sym if(!params[:text_placement_placement].nil?);

      @resource.settings(:text_formatting).show_all = params[:text_formatting_show_all].to_i;
      # Deprecated in new formatting style
      # @resource.settings(:text_formatting).collapse = (params[:text_formatting_collapse] == "collapse") ? 1 : 0;

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
      format.json { render :json => resp }
    end
  end


  #
  # Add single resource, return resource list as HTML
  #
  def add_child_resource
    begin
      # response

      # TODO: Check if user can relate to target
      add_child_resource_id = params[:add_child_resource_id]
      child_resource = Resource.find(add_child_resource_id)
      if(!child_resource.can(:view, current_user) and !child_resource.can(:edit, current_user))
        raise StandardError, 'Access Denied'
      end
      prel = ResourceHierarchy.where(resource_id: @resource.id, child_resource_id: add_child_resource_id).first_or_create

      resp = {:status => :ok, :html => render_to_string("resources/_resource_list_simple", layout: false)}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json { render :json => resp, status: :ok }
    end
  end

  #
  # Add one or more resources, return data
  #
  def add_child_resources
    # response

    # TODO: Check if user can relate to target
    add_child_resource_ids = params[:add_child_resource_ids]

    created = 0
    exists = 0

    resp = nil
    for add_child_resource_id in add_child_resource_ids
      begin
        child_resource = Resource.find(add_child_resource_id)
        if(!child_resource.can(:view, current_user) and !child_resource.can(:edit, current_user))
          raise StandardError, 'Access Denied'
        end
        if (@resource.is_collection)
          if (ResourceHierarchy.where(resource_id: @resource.id, child_resource_id: add_child_resource_id).length > 0)
            exists = exists + 1
          else
            prel = ResourceHierarchy.where(resource_id: @resource.id, child_resource_id: add_child_resource_id).create
            created = created + 1
          end
        elsif(@resource.is_resource)
          # if (MediaFile.joins(:sourceable).where(media_files: {resource_id: @resource.id}, sourceable: {resource_id: add_child_resource_id}).length > 0)
          if (ActiveRecord::Base.connection.execute("SELECT * FROM media_files mf INNER JOIN collectionobject_links AS l ON mf.sourceable_id = l.id WHERE mf.sourceable_type = 'CollectionobjectLink' AND mf.resource_id = " + @resource.id.to_s + " AND l.resource_id = " + add_child_resource_id.to_i.to_s).count > 0)
            exists = exists + 1
          else
            @media_file = MediaFile.new({
                                            caption: "",
                                            copyright_notes: "",
                                            access: true
                                        })
            @media_file.set_sourceable_media({collectionobject_link: {original_link: add_child_resource_id}});
			if (child_resource.is_collection_object)
			  @media_file.display_collectionobject_link = 1
			  @media_file.caption_type = 4
			  cap_fields = JSON.parse(child_resource.indexing_data)
			  long_caption = ''
			  if cap_fields['artist']
				long_caption += cap_fields['artist'].to_s + '<br/>'
			  end
			  if cap_fields['title']
			    long_caption += '<em>' + cap_fields['title'].to_s + '</em><br/>'
			  end
			  material_fields = ''
			  if cap_fields['support']
				material_fields = cap_fields['medium'].to_s + ' | ' + cap_fields['support'].to_s
			  else
				material_fields = cap_fields['medium'].to_s
			  end
			  if cap_fields['date_created']
			    long_caption += cap_fields['date_created'].to_s + '<br/>'
			  end
			  if material_fields != ''
				long_caption += material_fields.to_s + '<br/>'
			  end
			  if cap_fields['credit_line']
				long_caption += cap_fields['credit_line'].to_s + '<br/>'
			  end
			  if cap_fields['idno']
				long_caption += cap_fields['idno'].to_s
			  end
			  @media_file.caption = long_caption
			end
            # TODO: does user have access to this resource?
            @media_file.resource_id = @resource.id
            @media_file.save
            created = created + 1
          end
        end

      rescue StandardError => ex
        resp = {:status => :err, :error => ex.message}
        break
      end
    end

    resp = {:status => :ok, :numAdded => created, :numExisting => exists, :ids => add_child_resource_ids} if(!resp)
    respond_to do |format|
      format.json { render :json => resp, status: :ok }
    end
  end


  # add related resource
  def add_related_resource
    begin
      # response

      # TODO: Check if user can relate to target
      to_resource_id = params[:to_resource_id]
      to_resource = Resource.find(to_resource_id)
      if(!to_resource.can(:view, current_user) and !to_resource.can(:edit, current_user))
        raise StandardError, 'Access Denied'
      end
      prel = RelatedResource.where(resource_id: @resource.id, to_resource_id: to_resource_id, caption: params[:caption]).first_or_create

      @resource.update_search_index
      resp = {:status => :ok, :html => render_to_string("resources/_related", layout: false)}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json { render :json => resp, status: :ok }
    end
  end

  # remove related resource
  def remove_related_resource
    begin
      # TODO: Check if user can delete this
      to_resource_id = params[:related]
      to_resource = Resource.find(to_resource_id)
      if(!to_resource.can(:edit, current_user))
        raise StandardError, 'Delete Access Denied'
      end
      RelatedResource.where(resource_id: @resource.id, to_resource_id: to_resource_id).destroy_all

      @resource.update_search_index
      resp = {:status => :ok, :html => render_to_string("resources/_related", layout: false)}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json { render :json => resp }
    end
  end

  def edit_related_resource_caption
    # TODO: make sure user is allowed to do this for this resource
    if (r = RelatedResource.where(id: params[:related_id]).first)
      r.caption = params[:caption]
      if (r.save)
        resp = {status: :ok}
      else
        resp = {status: :error, msg: r.errors.full_messages.join('; ')}
      end

    else
      resp = {status: :error, msg: "No relationship found"}
    end

    respond_to do |format|
      format.json { render json: resp }
    end
  end


  def get_media_list
    resp = {status: :ok}

    # TODO: Check if user has access to resource for which media list is being generated

    start = params[:start].to_i
    start = 0 if ((start < 0) || (start.nil?) || (start > @resource.media_files.count))
    begin
      resp = {:status => :ok, :html => render_to_string("resources/_media_list", layout: false, locals: { start: start})}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json { render :json => resp }
    end
  end

  # set order of media
  def set_media_order
    resp = {status: :ok}

    # TODO: Check if user has access to resource for which media is being reordered
    offset = params[:offset].to_i

    # get current ranks for media
    current_media = MediaFile.where(resource_id: params[:id]).order(:rank)
    ranks = current_media.pluck(:rank)
    ranks = ranks.slice(offset, Rails.application.config.x.max_media_per_media_list_page)

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
      format.json { render :json => resp }
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
      format.json { render :json => resp }
    end
  end


  def set_link_order
    resp = {status: :ok}

    # TODO: Check if user has access to resource for which links are being reordered

    # get current ranks for links
    current_link = Link.where(resource_id: params[:id]).order(:rank)
    ranks = current_link.pluck(:rank)

    params[:ranks].each do |link_id|
      if (l = Link.where(resource_id: params[:id], id: link_id).first)
        l.rank = ranks.shift
        if (!l.save)
          resp = {:status => :err, :error => l.errors.full_messages.join('; ')}
          break
        end
      end
    end

    respond_to do |format|
      format.json { render :json => resp }
    end
  end

  def set_related_resource_order
    resp = {status: :ok}

    # TODO: Check if user has access to resource for which links are being reordered

    # get current ranks for related resources
    current_link = RelatedResource.where(resource_id: params[:id]).order(:rank)
    ranks = current_link.pluck(:rank)

    params[:ranks].each do |related_id|
      if (l = RelatedResource.where(resource_id: params[:id], id: related_id).first)
        l.rank = ranks.shift
        if (!l.save)
          resp = {:status => :err, :error => l.errors.full_messages.join('; ')}
          break
        end
      end
    end

    respond_to do |format|
      format.json { render :json => resp }
    end
  end


  #
  def set_response_info

    params.permit(:show)

    # TODO: Check if user has access to resource
    if (r = Resource.where({in_response_to_resource_id: params[:id], id: params[:response_id]}).first)
      begin
        r.response_banned_on = (params[:show].to_i == 1) ? 1 : 0
        r.save

        resp = {show: params[:show], status: :ok, :html => render_to_string("resources/_responses", layout: false)}
      rescue Exception => e
        resp = {:status => :err, :error => r.errors.full_messages.join('; ')}
      end
    else
      resp = {:status => :err, :error => "Not found"}
    end

    respond_to do |format|
      format.json { render :json => resp }
    end
  end

  #
  # User access list
  #
  def add_user_access
    # response
    begin
      # only owner can add user access
      if (!@resource.can(:edit, current_user))
        raise "Only owner can change access settings"
      end

      to_user_id = params[:to_user_id]
      access_type = params[:access_type]
      prel = ResourcesUser.where(resource_id: @resource.id, user_id: to_user_id, access: access_type).first_or_create

      resp = {:status => :ok, :html => render_to_string("resources/_access", layout: false)}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json { render :json => resp, status: :ok }
    end
  end

  def remove_user_access
    begin
      # only owner can add user access
      if (!@resource.can(:edit, current_user))
        raise "Only owner can change access settings"
      end
      user_id = params[:user_id]
      ResourcesUser.where(resource_id: @resource.id, user_id: user_id).destroy_all
      resp = {:status => :ok, :html => render_to_string("resources/_access", layout: false)}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json { render :json => resp }
    end
  end

  #
  # Group access list
  #
  def add_group_access
    # response
    begin
      # only owner can add user access
      if (!@resource.can(:edit, current_user))
        raise "Only owner can change access settings"
      end

      to_group_id = params[:to_group_id]
      access_type = params[:access_type]
      prel = ResourcesGroup.where(resource_id: @resource.id, group_id: to_group_id, access: access_type).first_or_create

      resp = {:status => :ok, :html => render_to_string("resources/_access", layout: false)}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json { render :json => resp, status: :ok }
    end
  end

  def remove_group_access
    begin
      # only owner can add user access
      if (!@resource.can(:edit, current_user))
        raise "Only owner can change access settings"
      end
      group_id = params[:group_id]
      ResourcesGroup.where(resource_id: @resource.id, group_id: group_id).destroy_all
      resp = {:status => :ok, :html => render_to_string("resources/_access", layout: false)}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json { render :json => resp }
    end
  end
  
  #
  # Methods below are for AJAX load of resources
  #
  def load_media_modal
  	f = MediaFile.find(params[:media_id])
  	r = Resource.find(params[:resource_id])
  	params.permit(:target_div, :media_id, :resource_title, :media_files, :editable, :resource_id)
  	target_div = '#media_editor_modal'
    @modal_data = {"target" => target_div, "id" => f.id, "title" => r.title, "editable" => params[:editable], "resource_id" => r.id}
    begin
		@media_display = f.sourceable.render :large
	rescue
		@media_display = f.sourceable.preview :large, caption: f.caption
	end
    
    respond_to do |format|
      format.js {render :action => "load_media_modal"}
    end
  end

  def load_fullscreen_slideshow
  	params.permit(:resource_id, :page)
    @slideshow_id = params[:resource_id]
    
    respond_to do |format|
      format.js {render :action => "load_fullscreen_slideshow"}
    end
  end

  def load_slides
  	offset = params[:page].to_i * 10
    res = Resource.find(params[:resource_id])
    new_slides = res.media_files.slice(offset, 10)
    media_file_list = []
    res.media_files.each do |mf|
    	media_file_list.push(mf)
    end
    new_slide_html = ''
    new_slides.each do |ns|
      if ns.sourceable
      	if ns.access == 1
      		begin
				media_display = ns.sourceable.render :large
			rescue
				media_display = ns.sourceable.preview :large, '', '', ns.caption
		  	end
			new_slide_html += '<div class="item"><div class="carouselImageHeight"><a class="modalOpen" href="#" id="link'
			new_slide_html += ns.sourceable.class.to_s + ns.sourceable.id.to_s + '"'
			new_slide_html +=  'data-link-target="#' +  ns.sourceable.class.to_s + ns.sourceable.id.to_s + 'Link">'
			new_slide_html += media_display
			new_slide_html += '</a></div>'
			if (fzoom = is_zoomable(ns))
				new_slide_html += "<div class='zoomControls' onload='$(this).css(\"top\", function(){ console.log($(this).prev().(\".previewMediaCaption.\").height() * -1);});'><a href='#' class='leafletZoom' data-dismiss='modal' onclick='$(\"#mediaViewerModal\").removeData(\"iiif\"); jQuery(\"#mediaViewerModal\").data(\"iiif\", \""
				new_slide_html += riiif_info_path(fzoom)
				new_slide_html += "\").modal(\"show\"); return false;'><i class='fa fa-search-plus' aria-hidden='true'></i>Zoom</a></div>"
			end
			new_slide_html += '</div>'
      	end
      end
    end
    respond_to do |format|
      format.html { render text: new_slide_html }
    end
  end

  def load_thumbnails
  	resp = {status: :ok}

    # TODO: Check if user has access to resource for which media list is being generated

    start = params[:start].to_i
    caption = params[:caption]
    start = 0 if ((start < 0) || (start.nil?) || (start > @resource.media_files.count))
    begin
      resp = {:status => :ok, :html => render_to_string("resources/_media_thumbnails", layout: false, locals: { start: start, caption: caption})}
    rescue StandardError => ex
      resp = {:status => :err, :error => ex.message}
    end

    respond_to do |format|
      format.json { render :json => resp }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_resource
    @resource = Resource.find(params[:id])
    if (@resource.is_crc_set && !current_user.has_role?(:staff))
      redirect_to root_path, notice: "That resource is not accessible"
    end
  end

  # return collections available to the current user
  def get_available_collections(resource)
    return nil if (!current_user)

    ids = resource.parents.pluck(:id)
    ids.push(resource.id)
    return Resource.where("resource_type = ? AND user_id = ? AND id NOT IN (?)", Resource::LEARNING_COLLECTION, current_user.id, ids).order(title: :asc)
  end

  #
  #
  #
  def get_available_collections_and_resources(resource)
    return nil if (!current_user)

    ids = resource.parents.pluck(:id)
    ids.push(resource.id)
    return Resource.where("resource_type IN (?) AND user_id = ? AND id NOT IN (?)", [Resource::LEARNING_COLLECTION, Resource::RESOURCE], current_user.id, ids).order(title: :asc)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    if ((current_user.has_role? :admin) || (current_user.has_role? :staff))
      params.require(:resource).permit(
          :slug, :title, :resource_type, :subtitle, :source_type, :source,
          :copyright_license, :rank, :user_id, :copyright_notes, :access, :body_text, :in_response_to_resource_id, :author_id
      )
    else
      params.require(:resource).permit(
          :slug, :title, :resource_type, :subtitle, :source_type, :source,
          :copyright_license, :rank, :user_id, :copyright_notes, :access, :body_text, :in_response_to_resource_id
      )
    end
  end
end
