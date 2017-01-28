class QuickSearchController < ApplicationController
  def query
    setup
  end

  def query_results
    setup

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
    setup(advanced:true)
  end


  #
  # Setup results for quicksearch and paging handler
  #
  private def setup(options=nil)
    params.permit(:query, :q, :page, :type, :length)
    @query = params[:q] if (!(@query = params[:query]))
    @page = params[:page].to_i
    @page = 1 if (@page < 1)
    @type = params[:type]   # restrict search to a specific result type (resources, collections, collection_objects, exhibitions)

    @length = params[:length].to_i

    puts "LENGTHS"
    puts session[:items_per_page]
    puts "GOT LENGTH=" + @length.to_s


    session[:items_per_page] = {} if (!session[:items_per_page])
    ['resource', 'collection', 'collection_object', 'exhibition'].map {|n| session[:items_per_page][n] = WillPaginate.per_page if (!session[:items_per_page].key?(n))}


    @length = session[:items_per_page][@type.to_s] if (@length <= 0)
    @length = WillPaginate.per_page if (@length < 10)

    session[:items_per_page][@type.to_s] = @length

    @items_per_page_defaults = session[:items_per_page]



    if (options && options[:advanced])
      params.permit(:type,
                    :title, :keywords, :style, :medium, :classification, :additional_classification,
                    :artist, :artist_nationality, :credit_line, :places, :on_display,
                    :date_created, :other_dates, :current_location, :exhibition_artist, :exhibition_artist_nationality, :exhibition_dates, :exhibition_location,
                    :min_rating, :max_rating
      )
      res = Resource::advancedsearch(params, models: true, page: @page, type: @type, length: @length)

      @query = res[:query]
      @query_for_display = res[:query_for_display]
    else
      res = Resource::quicksearch(@query, models: true, page: @page, type: @type, length: @length)
    end

    if (@type)
      session[:items_per_page][@type.to_s] = @length
    end

    case
      when (@type == 'resource')
        @resources = res[:resources]
        @resources_needs_paging = (@resources.total_entries > @length)
        @resources_num_pages = (@resources.total_entries / @length.to_f).ceil
        @resources_needs_previous_paging = (@page > 1)
        @resources_needs_next_paging = @resources_needs_paging && (@page < @resources_num_pages)
        @resources_page = @page
        @resources_count = @resources.respond_to?(:total_entries) ? @resources.total_entries : 0
      when (@type == 'collection')
        @collections = res[:collections]
        @collections_needs_paging = (@collections.total_entries > @length)
        @collections_num_pages = (@collections.total_entries / @length.to_f).ceil
        @collections_needs_previous_paging = (@page > 1)
        @collections_needs_next_paging = @collections_needs_paging && (@page < @collections_num_pages)
        @collections_page = @page
        @collections_count = @collections.respond_to?(:total_entries)  ? @collections.total_entries : 0
      when (@type == 'collection_object')
        @collection_objects = res[:collection_objects]
        @collection_objects_needs_paging = (@collection_objects.total_entries > @length)
        @collection_objects_num_pages = (@collection_objects.total_entries / @length.to_f).ceil
        @collection_objects_needs_previous_paging = (@page > 1)
        @collection_objects_needs_next_paging = @collection_objects_needs_paging && (@page < @collection_objects_num_pages)
        @collection_objects_page = @page
        @collection_objects_count = @collection_objects.respond_to?(:total_entries) ? @collection_objects.total_entries : 0
      when (@type == 'exhibition')
        @exhibitions = res[:exhibitions]
        @exhibitions_needs_paging = (@exhibitions.total_entries > @length)
        @exhibitions_num_pages = (@exhibitions.total_entries / @length.to_f).ceil
        @exhibitions_needs_previous_paging = (@page > 1)
        @exhibitions_needs_next_paging = @exhibitions_needs_paging && (@page < @exhibitions_num_pages)
        @exhibitions_page = @page
        @exhibitions_count = @exhibitions.respond_to?(:total_entries) ? @exhibitions.total_entries : 0
      else
        @resources = res[:resources]
        @resources_needs_paging = @resources.respond_to?(:total_entries) ? (@resources.total_entries > @length) : false
        @resources_num_pages = @resources_needs_paging ? (@resources.total_entries / @length.to_f).ceil : 1
        @resources_needs_previous_paging = false
        @resources_needs_next_paging = @resources_needs_paging
        @resources_page = @page
        @resources_count = @resources.respond_to?(:total_entries) ? @resources.total_entries : 0

        @collections = res[:collections]
        @collections_needs_paging = @collections.respond_to?(:total_entries) ? (@collections.total_entries > @length) : false
        @collections_num_pages = @collections_needs_paging ? (@collections.total_entries / @length.to_f).ceil : 1
        @collections_needs_previous_paging = false
        @collections_needs_next_paging = @collections_needs_paging
        @collections_page = @page
        @collections_count = @collections.respond_to?(:total_entries)  ? @collections.total_entries : 0

        @collection_objects = res[:collection_objects]
        @collection_objects_needs_paging = @collection_objects.respond_to?(:total_entries) ? (@collection_objects.total_entries > @length) : false
        @collection_objects_num_pages = @collection_objects_needs_paging ? (@collection_objects.total_entries / @length.to_f).ceil : 1
        @collection_objects_needs_previous_paging = false
        @collection_objects_needs_next_paging = @collection_objects_needs_paging
        @collection_objects_page = @page
        @collection_objects_count = @collection_objects.respond_to?(:total_entries) ? @collection_objects.total_entries : 0


        @exhibitions = res[:exhibitions]
        @exhibitions_needs_paging = @exhibitions.respond_to?(:total_entries) ?  (@exhibitions.total_entries > @length) : false
        @exhibitions_num_pages = @exhibitions_needs_paging ? (@exhibitions.total_entries / @length.to_f).ceil : 1
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
  end

end