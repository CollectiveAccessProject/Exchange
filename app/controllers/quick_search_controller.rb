class QuickSearchController < ApplicationController
  def query
    @query = params[:q]

    res = Resource::quicksearch(@query)
    @resources = res[:resources]
    @collections = res[:collections]
    @collection_objects = res[:collection_objects]
    @exhibitions = res[:exhibitions]
    @media_files = res[:media_files]

    session[:last_search_type] = :quick
    session[:last_search_query_display] = @query
    session[:last_search_query_elements] = [@query]
    session[:last_search_query] = @query
    session[:last_search_query_values] = {'q' => @query}
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
    @media_files = res[:media_files]

    @query = res[:query_for_display]

    # Set last search
    session[:last_search_type] = :advanced
    session[:last_search_query_display] = @query
    session[:last_search_query_elements] = res[:query_elements]
    session[:last_search_query] = res[:query_elements].join(" AND ")
    session[:last_search_query_values] = res[:query_values]
  end
end