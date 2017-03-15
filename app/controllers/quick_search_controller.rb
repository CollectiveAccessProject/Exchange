class QuickSearchController < ApplicationController
  def query
    begin
      setup
    rescue Exception => e
      redirect_to("/", :flash => { :error => "Search could not be completed: " + e.message })
    end
  end

  def query_results
    begin
      setup
    rescue
      raise "Search error"
    end

    params.permit(:type, :length)
    type = params[:type]
    l = params[:length]

    case
      when (type == "collection_object")
        resp = {:status => :ok, :page => @page, :type => type, :length => l, :query => @query, :html => render_to_string("quick_search/_collection_object_results", layout: false)}
      when (type == "resource")
        resp = {:status => :ok, :page => @page, :type => type, :length => l, :query => @query, :html => render_to_string("quick_search/_resource_results", layout: false)}
      when (type == "collection")
        resp = {:status => :ok, :page => @page, :type => type, :length => l, :query => @query, :html => render_to_string("quick_search/_collection_results", layout: false)}
      when (type == "exhibition")
        resp = {:status => :ok, :page => @page, :type => type, :length => l, :query => @query, :html => render_to_string("quick_search/_exhibition_results", layout: false)}
      else
        raise "Invalid type"
    end

    respond_to do |format|
      format.json { render :json => resp, status: :ok }
    end
  end



  def advanced
    begin
      setup(advanced:true)
    rescue
      raise "Search error"
    end
  end


  #
  # Setup results for quicksearch and paging handler
  #
  private def setup(options=nil)
    @available_collections = get_available_collections
    @available_collections_and_resources = get_available_collections_and_resources

    params.permit(:query, :q, :page, :type, :length, :sort)
    @query = params[:q] if (!(@query = params[:query]))
    @page = params[:page].to_i
    @page = 1 if (@page < 1)
    @type = params[:type]   # restrict search to a specific result type (resources, collections, collection_objects, exhibitions)

    @length = params[:length].to_i
    @sort = params[:sort]

    session[:items_per_page] = {} if (!session[:items_per_page])
    ['resource', 'collection', 'collection_object', 'exhibition'].map {|n| session[:items_per_page][n] = WillPaginate.per_page if (!session[:items_per_page].key?(n))}

    session[:sort] = {} if (!session[:sort])
    ['resource', 'collection', 'collection_object', 'exhibition'].map {|n| session[:sort][n] = "" if (!session[:sort].key?(n))}


    @length = itemsPerPageForType(session, @type) if (!@length || (@length <= 0))
    @sort = sortForType(session, @type) if (!@sort)

    session[:items_per_page][@type.to_s] = @length
    @items_per_page_defaults = session[:items_per_page]

    session[:sort][@type.to_s] = @sort
    @sort_defaults = session[:sort]


    if (options && options[:advanced])
      params.permit(:type,
                    :title, :keywords, :style, :medium, :classification, :additional_classification,
                    :artist, :artist_nationality, :credit_line, :places, :on_display,
                    :date_created, :other_dates, :current_location, :exhibition_artist, :exhibition_artist_nationality, :exhibition_dates, :exhibition_location,
                    :min_rating, :max_rating
      )
      res = Resource::advancedsearch(params, models: true, page: @page, type: @type, length: @length, lengthsByType: session[:items_per_page], sort: @sort, sortsByType: session[:sort])

      @query = res[:query]
      @query_for_display = res[:query_for_display]
    else
      res = Resource::quicksearch(@query, models: true, page: @page, type: @type, length: @length, lengthsByType: session[:items_per_page], sort: @sort, sortsByType: session[:sort])
    end

    if (@type)
      session[:items_per_page][@type.to_s] = @length
    end

    begin
      case
        when (@type == 'resource')
          @resources_length = @length
          @resources = res[:resources]
          @resources_needs_paging = (@resources.total_entries > @length)
          @resources_num_pages = (@resources.total_entries / @length.to_f).ceil
          @page = 1 if (@page > @resources_num_pages)
          @resources_needs_previous_paging = (@page > 1)
          @resources_needs_next_paging = @resources_needs_paging && (@page < @resources_num_pages)
          @resources_page = @page
          @resources_count = @resources.respond_to?(:total_entries) ? @resources.total_entries : 0
        when (@type == 'collection')
          @collections_length = @length
          @collections = res[:collections]
          @collections_needs_paging = (@collections.total_entries > @length)
          @collections_num_pages = (@collections.total_entries / @length.to_f).ceil
          @page = 1 if (@page > @collections_num_pages)
          @collections_needs_previous_paging = (@page > 1)
          @collections_needs_next_paging = @collections_needs_paging && (@page < @collections_num_pages)
          @collections_page = @page
          @collections_count = @collections.respond_to?(:total_entries)  ? @collections.total_entries : 0
        when (@type == 'collection_object')
          @collection_objects_length = @length
          @collection_objects_sort = @sort
          @collection_objects = res[:collection_objects]
          @collection_objects_needs_paging = (@collection_objects.total_entries > @length)
          @collection_objects_num_pages = (@collection_objects.total_entries / @length.to_f).ceil
          @page = 1 if (@page > @collection_objects_num_pages)
          @collection_objects_needs_previous_paging = (@page > 1)
          @collection_objects_needs_next_paging = @collection_objects_needs_paging && (@page < @collection_objects_num_pages)
          @collection_objects_page = @page
          @collection_objects_count = @collection_objects.respond_to?(:total_entries) ? @collection_objects.total_entries : 0
        when (@type == 'exhibition')
          @exhibitions_length = @length
          @exhibitions = res[:exhibitions]
          @exhibitions_needs_paging = (@exhibitions.total_entries > @length)
          @exhibitions_num_pages = (@exhibitions.total_entries / @length.to_f).ceil
          @page = 1 if (@page > @exhibitions_num_pages)
          @exhibitions_needs_previous_paging = (@page > 1)
          @exhibitions_needs_next_paging = @exhibitions_needs_paging && (@page < @exhibitions_num_pages)
          @exhibitions_page = @page
          @exhibitions_count = @exhibitions.respond_to?(:total_entries) ? @exhibitions.total_entries : 0
        else
          @resources_length = itemsPerPageForType(session, 'resource')
          @resources = res[:resources]
          @resources_needs_paging = @resources.respond_to?(:total_entries) ? (@resources.total_entries > @resources_length) : false
          @resources_num_pages = @resources_needs_paging ? (@resources.total_entries / @resources_length.to_f).ceil : 1
          @resources_needs_previous_paging = false
          @resources_needs_next_paging = @resources_needs_paging
          @resources_page = @page
          @resources_count = @resources.respond_to?(:total_entries) ? @resources.total_entries : 0

          @collections_length = itemsPerPageForType(session, 'collection')
          @collections = res[:collections]
          @collections_needs_paging = @collections.respond_to?(:total_entries) ? (@collections.total_entries > @collections_length) : false
          @collections_num_pages = @collections_needs_paging ? (@collections.total_entries / @collections_length.to_f).ceil : 1
          @collections_needs_previous_paging = false
          @collections_needs_next_paging = @collections_needs_paging
          @collections_page = @page
          @collections_count = @collections.respond_to?(:total_entries)  ? @collections.total_entries : 0

          @collection_objects_sort = sortForType(session, 'collection_object')
          @collection_objects_length = itemsPerPageForType(session, 'collection_object')
          @collection_objects = res[:collection_objects]
          @collection_objects_needs_paging = @collection_objects.respond_to?(:total_entries) ? (@collection_objects.total_entries > @collection_objects_length) : false
          @collection_objects_num_pages = @collection_objects_needs_paging ? (@collection_objects.total_entries / @collection_objects_length.to_f).ceil : 1
          @collection_objects_needs_previous_paging = false
          @collection_objects_needs_next_paging = @collection_objects_needs_paging
          @collection_objects_page = @page
          @collection_objects_count = @collection_objects.respond_to?(:total_entries) ? @collection_objects.total_entries : 0


          @exhibitions_length = itemsPerPageForType(session, 'exhibition')
          @exhibitions = res[:exhibitions]
          @exhibitions_needs_paging = @exhibitions.respond_to?(:total_entries) ?  (@exhibitions.total_entries > @exhibitions_length) : false
          @exhibitions_num_pages = @exhibitions_needs_paging ? (@exhibitions.total_entries / @exhibitions_length.to_f).ceil : 1
          @exhibitions_needs_previous_paging = false
          @exhibitions_needs_next_paging = @exhibitions_needs_paging
          @exhibitions_page = @page
          @exhibitions_count = @exhibitions.respond_to?(:total_entries) ? @exhibitions.total_entries : 0
      end


      if (options && options[:advanced])
        session[:last_search_type] = :advanced
        session[:last_search_query_display] = @query
        session[:last_search_query_elements] = res[:query_elements]
        session[:last_search_query] = res[:query_elements].join(" AND ")
        session[:last_search_query_values] = res[:query_values]
      else
        session[:last_search_type] = :quick
        session[:last_search_query_display] = @query
        session[:last_search_query_elements] = [@query]
        session[:last_search_query] = @query
        session[:last_search_query_values] = {:query => @query}
      end


      session[:last_search_results] = {
          resources: res[:resources].respond_to?(:pluck) ? res[:resources].pluck(:id) : [],
          collection_objects: res[:collection_objects].respond_to?(:pluck) ? res[:collection_objects].pluck(:id) : [],
          collections: res[:collections].respond_to?(:pluck) ? res[:collections].pluck(:id) : [],
          exhibitions: res[:exhibitions].respond_to?(:pluck) ? res[:exhibitions].pluck(:id) : []
      }

    rescue
      # search error
      raise "Search error"
    end
  end



  def itemsPerPageForType(session, type)
    length = session[:items_per_page][type.to_s]
    return WillPaginate.per_page if ((length == nil)|| !length || (length < 10))
    return length
  end

  def sortForType(session, type)
    sort = session[:sort][type.to_s]
    return "" if ((sort == nil)|| !sort)
    return sort
  end

  #
  #
  #
  def get_available_collections
    return nil if (!current_user)
    return Resource.where("resource_type = ? AND user_id = ?", Resource::LEARNING_COLLECTION, current_user.id).order(title_sort: :asc)
  end

  #
  #
  #
  def get_available_collections_and_resources
    return nil if (!current_user)
    return Resource.where("resource_type IN (?) AND user_id = ?", [Resource::LEARNING_COLLECTION, Resource::RESOURCE], current_user.id).order(title_sort: :asc)
  end
end