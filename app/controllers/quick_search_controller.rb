class QuickSearchController < ApplicationController
  def query
    setup
  end

  def query_results
    setup

    params.permit(:type)
    type = params[:type]

    case
      when (type == "collection_object")
        resp = {:status => :ok, :page => @page, :type => type, :query => @query, :html => render_to_string("quick_search/_collection_object_results", layout: false)}
      when (type == "resource")
        resp = {:status => :ok, :page => @page, :type => type, :query => @query, :html => render_to_string("quick_search/_resource_results", layout: false)}
      when (type == "collection")
        resp = {:status => :ok, :page => @page, :type => type, :query => @query, :html => render_to_string("quick_search/_collection_results", layout: false)}
      when (type == "exhibition")
        resp = {:status => :ok, :page => @page, :type => type, :query => @query, :html => render_to_string("quick_search/_exhibition_results", layout: false)}
      else
        raise "Invalid type"
    end

    respond_to do |format|
      format.json { render :json => resp, status: :ok }
    end
  end



  def advanced
    params.permit(:type,
                  :title, :keywords, :style, :medium, :classification, :additional_classification,
                  :artist, :artist_nationality, :credit_line, :places, :on_display,
                  :date_created, :other_dates, :current_location, :exhibition_artist, :exhibition_artist_nationality, :exhibition_dates, :exhibition_location
    )

    res = Resource::advancedsearch(params)
    @resources = res[:resources]
    @collections = res[:collections]
    @collection_objects = res[:collection_objects]
    @exhibitions = res[:exhibitions]

    @query = res[:query_for_display]

    # Set last search
    session[:last_search_type] = :advanced
    session[:last_search_query_display] = @query
    session[:last_search_query_elements] = res[:query_elements]
    session[:last_search_query] = res[:query_elements].join(" AND ")
    session[:last_search_query_values] = res[:query_values]
  end


  #
  # Setup results for quicksearch and paging handler
  #
  private def setup
    params.permit(:query, :q, :page, :type)
    @query = params[:q] if (!(@query = params[:query]))
    @page = params[:page].to_i
    @page = 1 if (@page < 1)
    @type = params[:type]   # restrict search to a specific result type (resources, collections, collection_objects, exhibitions)

    res = Resource::quicksearch(@query, models: true, page: @page, type: @type)

    case
      when (@type == 'resource')
        @resources = res[:resources]
        @resources_needs_paging = (@resources.total_entries > WillPaginate.per_page)
        @resources_num_pages = (@resources.total_entries / WillPaginate.per_page.to_f).ceil
        @resources_needs_previous_paging = (@page > 1)
        @resources_needs_next_paging = @resources_needs_paging && (@page < @resources_num_pages)
        @resources_page = @page
      when (@type == 'collection')
        @collections = res[:collections]
        @collections_needs_paging = (@collections.total_entries > WillPaginate.per_page)
        @collections_num_pages = (@collections.total_entries / WillPaginate.per_page.to_f).ceil
        @collections_needs_previous_paging = (@page > 1)
        @collections_needs_next_paging = @collections_needs_paging && (@page < @collections_num_pages)
        @collections_page = @page
      when (@type == 'collection_object')
        @collection_objects = res[:collection_objects]
        @collection_objects_needs_paging = (@collection_objects.total_entries > WillPaginate.per_page)
        @collection_objects_num_pages = (@collection_objects.total_entries / WillPaginate.per_page.to_f).ceil
        @collection_objects_needs_previous_paging = (@page > 1)
        @collection_objects_needs_next_paging = @collection_objects_needs_paging && (@page < @collection_objects_num_pages)
        @collection_objects_page = @page
      when (@type == 'exhibition')
        @exhibitions = res[:exhibitions]
        @exhibitions_needs_paging = (@exhibitions.total_entries > WillPaginate.per_page)
        @exhibitions_num_pages = (@exhibitions.total_entries / WillPaginate.per_page.to_f).ceil
        @exhibitions_needs_previous_paging = (@page > 1)
        @exhibitions_needs_next_paging = @exhibitions_needs_paging && (@page < @exhibitions_num_pages)
        @exhibitions_page = @page
      else
        @resources = res[:resources]
        @resources_needs_paging = (@resources.total_entries > WillPaginate.per_page)
        @resources_num_pages = (@resources.total_entries / WillPaginate.per_page.to_f).ceil
        @resources_needs_previous_paging = false
        @resources_needs_next_paging = @resources_needs_paging
        @resources_page = @page

        @collections = res[:collections]
        @collections_needs_paging = (@collections.total_entries > WillPaginate.per_page)
        @collections_num_pages = (@collections.total_entries / WillPaginate.per_page.to_f).ceil
        @collections_needs_previous_paging = false
        @collections_needs_next_paging = @collections_needs_paging
        @collections_page = @page

        @collection_objects = res[:collection_objects]
        @collection_objects_needs_paging = (@collection_objects.total_entries > WillPaginate.per_page)
        @collection_objects_num_pages = (@collection_objects.total_entries / WillPaginate.per_page.to_f).ceil
        @collection_objects_needs_previous_paging = false
        @collection_objects_needs_next_paging = @collection_objects_needs_paging
        @collection_objects_page = @page


        @exhibitions = res[:exhibitions]
        @exhibitions_needs_paging = (@exhibitions.total_entries > WillPaginate.per_page)
        @exhibitions_num_pages = (@exhibitions.total_entries / WillPaginate.per_page.to_f).ceil
        @exhibitions_needs_previous_paging = false
        @exhibitions_needs_next_paging = @exhibitions_needs_paging
        @exhibitions_page = @page
    end


    session[:last_search_type] = :quick
    session[:last_search_query_display] = @query
    session[:last_search_query_elements] = [@query]
    session[:last_search_query] = @query
    session[:last_search_query_values] = {:query => @query}
  end

end