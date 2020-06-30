class QuickSearchController < ApplicationController

  # UI autocomplete on resource title (used by related resources lookup)
  autocomplete :resource, :title, :full => true, :extra_data => [:id, :collection_identifier, :resource_type, :indexing_data], :display_value => :get_autocomplete_label

  def autocomplete_resource_title
    params.permit(:term, :mode)
    term = params[:term]
    mode = params[:mode]
    
    if !current_user or !current_user.id
        raise "Not logged in"
    end
    editable_resources = Resource.where("user_id = ? OR author_id = ?", current_user.id, current_user.id)
    editable_res = ResourcesUser.where('user_id=? AND access >= ?', current_user.id, 2)
    
    group_ids = groups_for_user(current_user, { ids: true })
    
    if group_ids and group_ids.length > 0
        editable_res = editable_res + ResourcesGroup.where('group_id IN (?) AND access >= ?', group_ids, 2)
    end
    
    rids = editable_res.map {|x| x.resource_id}
    rids = rids + editable_resources.map { |x| x.id }
    
	if rids and rids.length > 0
        u = Resource.where(
            '(LOWER(resources.title) LIKE ? OR LOWER(resources.collection_identifier) LIKE ?) AND resources.resource_type IN (?) AND (resources.id IN (?) OR resources.author_id = ? OR resources.user_id = ?)',
            "%#{term}%", "#{term}%", ((mode == Resource::COLLECTION) ? [Resource::COLLECTION] : [Resource::COLLECTION, Resource::RESOURCE, Resource::CRCSET]), rids, current_user.id, current_user.id
        ).order(:id).all
    else 
       u = Resource.where(
            '(LOWER(resources.title) LIKE ? OR LOWER(resources.collection_identifier) LIKE ?) AND resources.resource_type IN (?) AND (resources.author_id = ? OR resources.user_id = ?)',
            "%#{term}%", "#{term}%", ((mode == Resource::COLLECTION) ? [Resource::COLLECTION] : [Resource::COLLECTION, Resource::RESOURCE, Resource::CRCSET]), current_user.id, current_user.id
        ).order(:id).all
    end
        
    d = u.map { |r|  {:id => r.id, :label => (l = r.get_autocomplete_label), :value => l, :indexing_data => r.indexing_data} }
    render :json => d
  end
  
  #
  # Generic autocompleter for refine
  #
  def autocomplete_refine
    params.permit(:field, :term, :query, :size, :type).require(:field)
    
    f = params[:field]
    t = params[:term].downcase
    q = params[:query]
    type = params[:type]
    s = params[:size] || 250
    
    
    q.gsub!(/(?<=^|\s)([\d]+[A-Za-z0-9\.\/\-&\*]+)/, '"\1"')
    q.gsub!(/["]{2}/, '"')
    
    refine_q = ''
    if session[:refine] and session[:refine][type] and (session[:refine][type].length > 0)
        refine_q = Resource::get_refine_facet_query(session[:refine], type)
    end
    
    q_type = " resource_type:" + Resource::resource_text_to_type(type).to_s

    
    agg = Resource.search(
        query: {
            query_string:  {
                default_operator: "AND",
                query: q + q_type + refine_q
            }
        },
        size: 10000,
        aggs: {
            values: { terms: { field: f, size: s } }
        }
    )
	d = agg.response["aggregations"]["values"]["buckets"].reduce([]) do |acc,v|
        if v['key'].downcase.include?(t)
            val = v['key'].gsub(/<\/?[^>]*>/, "")
            acc.push({:id => val, :label => val, :value => val})
        end 
        acc
    end   
    render :json => d
  end

  def query
    begin
      setup
    rescue Exception => e
      redirect_to("/", :flash => { :error => "Search could not be completed" })
    end
  end

  def query_results
    begin
      setup
    rescue Exception => e
      #raise "Search error: " + e.message
     redirect_to("/", :flash => { :error => "Search could not be completed"})
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
      when (type == "crcset")
        resp = {:status => :ok, :page => @page, :type => type, :length => l, :query => @query, :html => render_to_string("quick_search/_crc_set_results", layout: false)}
      else
        #raise "Invalid type"
        redirect_to("/", :flash => { :error => "Search could not be completed: invalid type" })
        return
    end

    respond_to do |format|
      format.json { render :json => resp, status: :ok }
    end
  end



  def advanced
    begin
      setup(advanced:true)
    rescue Exception => e
      #raise "Search error: " + e.message
      redirect_to("/", :flash => { :error => "Search could not be completed" })
    end
  end


  #
  # Setup results for quicksearch and paging handler
  #
  private def setup(options=nil)
    @show = true
    @available_collections = get_available_collections
    @available_collections_and_resources = get_available_collections_and_resources

    params.permit(:query, :q, :page, :type, :length, :sort, refine: [], unrefine:[])

    @query = params[:q] if (!(@query = params[:query]))
    @query = "*" if (@query and @query.length == 0)
    
    if session[:last_search_query]  != @query
        session[:refine] = {}
    end
    
    @query_proc = @query.dup if @query
    
    @query_proc = @query.gsub(/[^[:word:]\s\/\-\.\:\_\*\"]/, '') if @query_proc
    @query_proc = self.dates_to_lucene(@query_proc) if @query_proc
    
    @page = params[:page].to_i
    @page = 1 if (@page < 1)
    @type = params[:type]   # restrict search to a specific result type (resources, collections, collection_objects, exhibitions)

    @length = params[:length].to_i
    @sort = params[:sort]
    
    #Rails.logger.info("QQQ " + @query_proc);
    # Handle removal of filter
    if params[:unrefine] and session[:refine] and session[:refine][@type]
        params[:unrefine].each do|u|
            ubits = u.split(/:/)
            
            if session[:refine][@type].has_key? ubits[0]
                session[:refine][@type][ubits[0]].select! do |a| 
                    a != u
                end
            end    
        end
        
    end
    
    
    # rewrite for date search
    @query_proc = @query_proc.gsub(/date_created:["]*([\d]+)["]*[ ]+(TO|-|–)[ ]+["]*([\d]+)["]*/i, '(start_date:>=\\1' + ' AND end_date:<=\\3)') if @query_proc
    @query_proc = @query_proc.gsub(/date_created:["]*([\d]+)["]*/, '(start_date:<=\\1' + ' AND end_date:>=\\1)') if @query_proc

    # rewrite for updated_at search
    if @query_proc
        begin 
            m = @query_proc.match(/(updated_at|date_of_visit):["]*([\d\-]+)["]*[ ]+(TO|-|–)[ ]+["]*([\d\-]+)["]*/i)
            if m and (Date.strptime(m[2], '%Y-%m-%d').to_time.to_i <= Date.strptime(m[4], '%Y-%m-%d').to_time.to_i)
                @query_proc = @query_proc.gsub(/(updated_at|date_of_visit):["]*([\d\-]+)["]*[ ]+(TO|-|–)[ ]+["]*([\d\-]+)["]*/i, '(updated_at|date_of_visit):[\\2 TO \\4]')
            elsif !m
                @query_proc = @query_proc.gsub(/(updated_at|date_of_visit):["]*([\d\-]+)["]*/, '[\\2 TO \\2]')
            end
        rescue
            # noop
        end
    end

    # rewrite on_display
    @query_proc = @query_proc.gsub(/on_display:["]*([A-Za-z]+)["]*/, 'on_display:1') if @query_proc
    
    # rewrite rating
    #@query_proc = @query_proc.gsub(/rating:(\[[1-9]+ TO 5\])/, '(rating:\\1 OR rating:0)') if @query_proc

    session[:items_per_page] = {} if (!session[:items_per_page])
    ['resource', 'collection', 'collection_object', 'exhibition', 'crcset'].map {|n| session[:items_per_page][n] = WillPaginate.per_page if (!session[:items_per_page].key?(n))}

    session[:sort] = {} if (!session[:sort])
    ['resource', 'collection', 'collection_object', 'exhibition', 'crcset'].map {|n| session[:sort][n] = "" if (!session[:sort].key?(n))}


    @length = items_per_page_for_type(session, @type) if (!@length || (@length <= 0))
    @sort = sort_for_type(session, @type) if (!@sort)

    session[:items_per_page][@type.to_s] = @length
    @items_per_page_defaults = session[:items_per_page]

    session[:sort][@type.to_s] = @sort
    @sort_defaults = session[:sort]


    if (options && options[:advanced])
      params.permit(:type,
                    :title, :keywords, :style, :medium, :classification, :additional_classification,
                    :artist, :artist_nationality, :credit_line, :places, :on_display, :collection_identifier,
                    :date_created, :other_dates, :location, :exhibition_artist, :exhibition_artist_nationality, :exhibition_dates, :exhibition_location,
                    :min_rating, :max_rating
      )
      res = Resource::advancedsearch(params, models: true, page: @page, type: @type, length: @length, lengthsByType: session[:items_per_page], sort: @sort, sortsByType: session[:sort], user: current_user)

      @query = res[:query_string]
      @query_for_display = res[:query_for_display]
    else
        # Handle adding of refine filter
        @refine = {}
        if session[:last_search_query]  != @query
            session[:refine] = {}
        else 
            @refine = session[:refine] if session[:refine]
        end
        if (@type)
            if params[:refine]
                @refine[@type] = {} if @refine[@type] == nil
                params[:refine].each { |p|
                    pbits = p.split(/:/)
                    
                    case(pbits[0])
                        when 'updated_at'
                            begin 
                                m = p.match(/updated_at:\[([\d\-]+)["]*[ ]+(TO|-|–)[ ]+["]*([\d\-]+)\]/i)
                                next if !m
                                next if !((Date.strptime(m[1], '%Y-%m-%d').to_time.to_i <= Date.strptime(m[3], '%Y-%m-%d').to_time.to_i))
                            rescue
                                next
                            end
                        when 'date_of_visit'
                            begin 
                                m = p.match(/date_of_visit:\[([\d\-]+)["]*[ ]+(TO|-|–)[ ]+["]*([\d\-]+)\]/i)
                                next if !m
                                next if !((Date.strptime(m[1], '%Y-%m-%d').to_time.to_i <= Date.strptime(m[3], '%Y-%m-%d').to_time.to_i))
                            rescue
                                next
                            end
                    end
                    
                    @refine[@type][pbits[0]] = [] if !@refine[@type].has_key? pbits[0]
                    @refine[@type][pbits[0]].push(p) if !@refine[@type][pbits[0]].include? p
                }
                session[:refine] = @refine
            end
        end
    
      res = Resource::quicksearch(@query_proc, models: true, refine: @refine, page: @page, type: @type, length: @length, lengthsByType: session[:items_per_page], sort: @sort, sortsByType: session[:sort], user: current_user)
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
        when (@type == 'crcset')
          @crcsets_length = @length
          @crcsets = res[:crcsets]
          @crcsets_needs_paging = (@crcsets.total_entries > @length)
          @crcsets_num_pages = (@crcsets.total_entries / @length.to_f).ceil
          @page = 1 if (@page > @crcsets_num_pages)
          @crcsets_needs_previous_paging = (@page > 1)
          @crcsets_needs_next_paging = @crcsets_needs_paging && (@page < @crcsets_num_pages)
          @crcsets_page = @page
          @crcsets_count = @crcsets.respond_to?(:total_entries) ? @crcsets.total_entries : 0
        else
          @resources_length = items_per_page_for_type(session, 'resource')
          @resources = res[:resources]
          @resources_needs_paging = @resources.respond_to?(:total_entries) ? (@resources.total_entries > @resources_length) : false
          @resources_num_pages = @resources_needs_paging ? (@resources.total_entries / @resources_length.to_f).ceil : 1
          @resources_needs_previous_paging = false
          @resources_needs_next_paging = @resources_needs_paging
          @resources_page = (@resources_num_pages < @page) ? 1 : @page
          @resources_count = @resources.respond_to?(:total_entries) ? @resources.total_entries : 0

          @collections_length = items_per_page_for_type(session, 'collection')
          @collections = res[:collections]
          @collections_needs_paging = @collections.respond_to?(:total_entries) ? (@collections.total_entries > @collections_length) : false
          @collections_num_pages = @collections_needs_paging ? (@collections.total_entries / @collections_length.to_f).ceil : 1
          @collections_needs_previous_paging = false
          @collections_needs_next_paging = @collections_needs_paging
          @collections_page = (@collections_num_pages < @page) ? 1 : @page
          @collections_count = @collections.respond_to?(:total_entries)  ? @collections.total_entries : 0

          @collection_objects_sort = sort_for_type(session, 'collection_object')
          @collection_objects_length = items_per_page_for_type(session, 'collection_object')
          @collection_objects = res[:collection_objects]
          @collection_objects_needs_paging = @collection_objects.respond_to?(:total_entries) ? (@collection_objects.total_entries > @collection_objects_length) : false
          @collection_objects_num_pages = @collection_objects_needs_paging ? (@collection_objects.total_entries / @collection_objects_length.to_f).ceil : 1
          @collection_objects_needs_previous_paging = false
          @collection_objects_needs_next_paging = @collection_objects_needs_paging
          @collection_objects_page = (@collection_objects_num_pages < @page) ? 1 : @page
          @collection_objects_count = @collection_objects.respond_to?(:total_entries) ? @collection_objects.total_entries : 0

          @exhibitions_length = items_per_page_for_type(session, 'exhibition')
          @exhibitions = res[:exhibitions]
          @exhibitions_needs_paging = @exhibitions.respond_to?(:total_entries) ?  (@exhibitions.total_entries > @exhibitions_length) : false
          @exhibitions_num_pages = @exhibitions_needs_paging ? (@exhibitions.total_entries / @exhibitions_length.to_f).ceil : 1
          @exhibitions_needs_previous_paging = false
          @exhibitions_needs_next_paging = @exhibitions_needs_paging
          @exhibitions_page = (@exhibitions_num_pages < @page) ? 1 : @page
          @exhibitions_count = @exhibitions.respond_to?(:total_entries) ? @exhibitions.total_entries : 0

          @crcsets_length = items_per_page_for_type(session, 'crcset')
          @crcsets = res[:crcsets]
          @crcsets_needs_paging = @crcsets.respond_to?(:total_entries) ?  (@crcsets.total_entries > @crcsets_length) : false
          @crcsets_num_pages = @crcsets_needs_paging ? (@crcsets.total_entries / @crcsets_length.to_f).ceil : 1
          @crcsets_needs_previous_paging = false
          @crcsets_needs_next_paging = @crcsets_needs_paging
          @crcsets_page = (@crcsets_num_pages < @page) ? 1 : @page
          @crcsets_count = @crcsets.respond_to?(:total_entries) ? @crcsets.total_entries : 0
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


      @is_staff = current_user && current_user.has_role?(:staff)

      session[:last_search_results] = {
          resources: res[:resources].respond_to?(:pluck) ? res[:resources].pluck(:id) : [],
          collection_objects: res[:collection_objects].respond_to?(:pluck) ? res[:collection_objects].pluck(:id) : [],
          collections: res[:collections].respond_to?(:pluck) ? res[:collections].pluck(:id) : [],
          exhibitions: res[:exhibitions].respond_to?(:pluck) ? res[:exhibitions].pluck(:id) : [],
          crcsets: (@is_staff && res[:crcsets].respond_to?(:pluck)) ? res[:crcsets].pluck(:id) : []
      }

    rescue Exception => e
      #raise "Search error: " + e.message + @query
      redirect_to("/", :flash => { :error => "Search could not be completed" })
    end
  end



  def items_per_page_for_type(session, type)
    length = session[:items_per_page][type.to_s]
    return WillPaginate.per_page if ((length == nil)|| !length || (length < 10))
    return length
  end

  def sort_for_type(session, type)
    sort = session[:sort][type.to_s]
    return "" if ((sort == nil)|| !sort)
    return sort
  end

  #
  #
  #
  def dates_to_lucene(expr)
  	
    # Full range
    expr = expr.gsub(/created:([\d+]{4})-([\d]{1,2})-([\d]{1,2})-([\d+]{4})-([\d]{1,2})-([\d]{1,2})/, "created_at:[\\1-\\2-\\3 TO \\4-\\5-\\6]")
    expr = expr.gsub(/updated:([\d+]{4})-([\d]{1,2})-([\d]{1,2})-([\d+]{4})-([\d]{1,2})-([\d]{1,2})/, "updated_at:[\\1-\\2-\\3 TO \41-\\5-\\6]")
    
    # Single day
    expr = expr.gsub(/created:([\d+]{4})-([\d]{1,2})-([\d]{1,2})/, "created_at:[\\1-\\2-\\3 TO \\1-\\2-\\3]")
    expr = expr.gsub(/updated:([\d+]{4})-([\d]{1,2})-([\d]{1,2})/, "updated_at:[\\1-\\2-\\3 TO \\1-\\2-\\3]")
    
    # year range
    expr = expr.gsub(/created:([\d+]{4})-([\d+]{4})/, "created_at:[\\1-01-01 TO \\2-12-31]")
    expr = expr.gsub(/updated:([\d+]{4})-([\d+]{4})/, "updated_at:[\\1-01-01 TO \\2-12-31]")
    
  	# Single month
    expr = expr.gsub(/created:([\d+]{4})-([\d]{1,2})/, "created_at:[\\1-\\2-01 TO \\1-\\2-31]")
    expr = expr.gsub(/updated:([\d+]{4})-([\d]{1,2})/, "updated_at:[\\1-\\2-01 TO \\1-\\2-31]")
    
  	# Single year
    expr = expr.gsub(/created:([\d+]{4})/, "created_at:[\\1-01-01 TO \\1-12-31]")
    expr = expr.gsub(/updated:([\d+]{4})/, "updated_at:[\\1-01-01 TO \\1-12-31]")
    
    
    
    expr
  end
  
  #
  #
  #
  def get_available_collections
    return nil if (!current_user)
    # Get Resources for users from Resources and ResourcesUser
  	collections = []
  	editable_res = ResourcesUser.where('user_id=? AND access=?', current_user.id, 2)
    editable_res.each do |ed|
    	editable_colls = Resource.where('id = ? AND resource_type = ?', ed.resource_id, Resource::COLLECTION)
    	editable_colls.each do |coll|
    		collections.push(Resource.find(coll.id))
    	end
    end
    user_res = Resource.where('(user_id=? OR author_id=?) AND resource_type = ? ', current_user.id, current_user.id, Resource::COLLECTION)
	user_res.each do |us|
		collections.push(Resource.find(us.id))
	end
    return collections
  end

  #
  #
  #
  def get_available_collections_and_resources
    return nil if (!current_user)
     # Get Resources for users from Resources and ResourcesUser
  	resources = []
  	editable_res = ResourcesUser.where('user_id=? AND access=?', current_user.id, 2)
    editable_res.each do |ed|
    	resources.push(Resource.find(ed.resource_id))
    end
    user_res = Resource.where('(user_id=? OR author_id=?) AND resource_type IN (?) ', current_user.id, current_user.id, [Resource::COLLECTION, Resource::RESOURCE]).order(title_sort: :asc)
	user_res.each do |us|
		resources.push(Resource.find(us.id))
	end
    return resources
  end
end
