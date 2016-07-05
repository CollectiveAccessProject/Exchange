class QuickSearchController < ApplicationController
  def query
    @query = params[:q]

    res = Resource::quicksearch(@query)
    @resources = res[:resources]
    @collections = res[:collections]
    @collection_objects = res[:collection_objects]
    @exhibitions = res[:exhibitions]
    @media_files = res[:media_files]
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
  end
end