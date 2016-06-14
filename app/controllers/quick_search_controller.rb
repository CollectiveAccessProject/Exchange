class QuickSearchController < ApplicationController
  def query
    @query = params[:q]

    res = Resource::quicksearch(@query)
    @resources = res[:resources]
    @collections = res[:collections]
    @media_files = res[:media_files]
  end
end