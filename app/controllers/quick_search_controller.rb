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
end