class QuickSearchController < ApplicationController
  def query
    @query = params[:q]

    # @todo: this should be a model method .. or in fact all of this
    # controller code should be in a model, class, module or whatever

    @resources = Resource.search(@query + " AND resource_type:1").map do |r|
      if r._source
        { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type }
      end
    end

    @collections = Resource.search(@query + " AND resource_type:2").map do |r|
      if r._source
        { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type }
      end
    end


    @media_files = MediaFile.search(@query).map do |r|
      if r._source
        { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_id: r._source.resource_id }
      end
    end
  end
end
