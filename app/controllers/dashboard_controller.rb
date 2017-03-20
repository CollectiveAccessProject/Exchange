class DashboardController < ApplicationController
  before_filter :authenticate_user!

  before_filter :init_resources

  def index
	
	# User's Resources are generated in the method below
	
	# user activity history
    activity_history = PaperTrail::Version.where('whodunnit = ?', current_user.id).order(:created_at => :desc).limit(20)

    @activity_history = []
    activity_history.each do |h|
      is_delete = false

      created_at = h.created_at
      if (!h.item)
        created_at = h.created_at
        is_delete = true
        item = h.reify
      else
        item = h.item
      end

      next if (!item)

      event_disp = (is_delete) ? "deleted" : h.event + "d"
      event_disp[0] = event_disp[0].capitalize

      item_type = h.item_type.downcase

      case(item_type)
        when 'resource'
          t = item.title
          item_type_disp = item.resource_type_for_display
        when 'mediafile'
          t = item.slug
          item = item.resource
          item_type_disp = "Media"
        else
          next
      end

      @activity_history.push({event: event_disp, title: t, item: item, item_type: item_type_disp, datetime: created_at.strftime("%m/%d/%y at %H:%M:%S"), created_at: created_at, deleted: is_delete})

    end

    # user favorites
    @favorites = Favorite.where(user_id: current_user.id)
 
  end
  
  #
  # Sort and Filter a users items on their Dashboard
  #
  def filter_user_items
  	# If user is applying new filter, save that
  	if params[:pub_filter] != nil
  		session[:access_filter] = params[:pub_filter]
  	elsif params[:type_filter] != nil
  		session[:type_filter] = params[:type_filter]
  	end
  	
  	# Get filtered array of resource objects
  	@filtered = []
  	if session[:access_filter] && session[:type_filter] 
  		@resources.each do |sort|
  			if sort.access.to_i == session[:access_filter].to_i and sort.resource_type.to_i == session[:type_filter].to_i
  				@filtered.push(Resource.find(sort.id))
  			end
  		end
  	elsif session[:access_filter]
  		@resources.each do |sort|
  			if sort.access.to_i == session[:access_filter].to_i
  				@filtered.push(Resource.find(sort.id))
  			end
  		end
  	elsif session[:type_filter]
  		@resources.each do |sort|
  			if sort.resource_type.to_i == session[:type_filter].to_i
  				@filtered.push(Resource.find(sort.id))
  			end
  		end
  	else
  		@filtered = @resources
  	end
  	
  	# Apply a sort to the objects if necessary
  	
  	if params[:sort_type]
  		session[:dash_sort] = params[:sort_type]
  	end
  	
  	if session[:dash_sort] == 'title'
  		@filtered = @filtered.sort_by { |resource| ActionController::Base.helpers.strip_tags(resource.read_attribute(session[:dash_sort])) }
  	elsif session[:dash_sort]
  		@filtered = @filtered.sort_by { |resource| resource.read_attribute(session[:dash_sort]) }.reverse!
  	else
  		@filtered = @filtered
  	end
  	
  	respond_to do |format|
  	  format.js { render :action => "filter_user_items" }
  	end
  end
  
  def remove_filter
  	session.delete(:access_filter)
  	session.delete(:type_filter)
  	session.delete(:dash_sort)
  	@filtered = @resources
  	respond_to do |format|
  	  format.js { render :action => "filter_user_items" }
  	end
  end
  
  def init_resources
  	# Get Resources for users from Resources and ResourcesUser
  	@resources = []
  	@counts = {collections: 0, resources: 0, collection_objects: 0}
  	editable_res = ResourcesUser.where('user_id=? AND access=?', current_user.id, 2)
    editable_res.each do |ed|
    	@resources.push(Resource.find(ed.resource_id))
    end
    user_res = Resource.where('user_id=? OR author_id=? ', current_user.id, current_user.id)
	user_res.each do |us|
		@resources.push(Resource.find(us.id))
	end
	@resources.each do |res|
		if res.resource_type == Resource::RESOURCE
			@counts[:resources] += 1
		elsif res.resource_type == Resource::COLLECTION
			@counts[:collections] += 1
		elsif res.resource_type == Resource::COLLECTION_OBJECT
			@counts[:collection_objects] += 1
		end
	end
  end
end
