class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
    @resources = Resource.where('user_id=? OR author_id=?', current_user.id, current_user.id)

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


      # user favorites
      @favorites = Favorite.where(user_id: current_user.id)
    end

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
  	if session[:access_filter] && session[:type_filter] 
  		filtered_temp = Resource.where('access = ? AND resource_type = ? AND (user_id = ? OR author_id=?)', session[:access_filter], session[:type_filter] , current_user.id, current_user.id)
  	elsif session[:access_filter]
  		filtered_temp = Resource.where('access = ? AND (user_id = ? OR author_id = ?', session[:access_filter], current_user.id, current_user.id)
  	elsif session[:type_filter]
  		filtered_temp = Resource.where('resource_type = ? AND (user_id = ? OR author_id = ?)', session[:type_filter] , current_user.id, current_user.id)
  	else
  		filtered_temp = Resource.where('user_id = ? OR author_id = ?', current_user.id, current_user.id)
  	end
  	
  	# Apply a sort to the objects if necessary
  	
  	if params[:sort_type]
  		session[:dash_sort] = params[:sort_type]
  	end
  	
  	if session[:dash_sort] == 'title'
  		@filtered = filtered_temp.sort_by { |resource| ActionController::Base.helpers.strip_tags(resource.read_attribute(session[:dash_sort])) }
  	elsif session[:dash_sort]
  		@filtered = filtered_temp.sort_by { |resource| resource.read_attribute(session[:dash_sort]) }.reverse!
  	else
  		@filtered = filtered_temp
  	end
  	
  	respond_to do |format|
  	  format.js { render :action => "filter_user_items" }
  	end
  end
  
  def remove_filter
  	session.delete(:access_filter)
  	session.delete(:type_filter)
  	session.delete(:dash_sort)
  	@filtered = Resource.where('user_id = ? OR author_id', current_user.id, current_user.id)
  	respond_to do |format|
  	  format.js { render :action => "filter_user_items" }
  	end
  end
end
