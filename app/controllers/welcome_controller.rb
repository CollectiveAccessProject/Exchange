class WelcomeController < ApplicationController
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
  def index

    @is_staff = current_user && current_user.has_role?(:staff)
    @featured_content_set = FeaturedContentSet.where(slug: "front-page", access: 1).first
    
    params[:q] = session[:last_search_query] if params[:q].nil?
    params[:q] = '*' if params[:q].nil?
    
    @query =  params[:q]
    
    @suggested_search_terms = [
    	"rivers and streams",
    	"japanese pottery",
    	"fashion photography",
    	"abstract expressionism",
    	"hudson school",
    	"puppies",
    	"ceremonial jewelry",
    	"polaroid",
    	"portraits"
    ].sample(3)
    
    
    session[:last_search_query] = @query
  end
  
  def search
  	params.permit(:page)
  	@page = params[:page].to_i
    @page = 1 if (@page < 1)
  	params[:type] = '_all'
  	
    @show_header = true
    @show_header = false if params[:page] and params[:page].to_i > 1
  	
    begin
      setup
     rescue Exception => e
       redirect_to("/", :flash => { :error => "Search could not be completed" })
    end
    
    
    respond_to do |format|
      format.html {render layout: false}
      format.js {}
    end
  end
  
  def refinepanel
  	
    @query = session[:last_search_query]
    @query = "" if @query.nil?
	respond_to do |format|
      format.html { render layout: false }
    end
  end
  
   def refine
  	params[:type] = '_all'
  	@page = params[:page].to_i
    @page = 1 if (@page < 1)
    
    @query = params[:q] = session[:last_search_query]
  	
    @show_header = true
    @show_header = false if params[:page] and params[:page].to_i > 1
    
    begin
      setup
    rescue Exception => e
      #raise "Search error: " + e.message
     redirect_to("/", :flash => { :error => "Search could not be completed"})
    end


    resp = {:status => :ok, :query => @query, :html => render_to_string("welcome/_welcome_search_results", layout: false)}

    respond_to do |format|
      format.json { render :json => resp, status: :ok }
    end
  end

  
    #
  # Setup results for quicksearch and paging handler
  #
  private def setup(options=nil)
    @show = true
    params.permit(:query, :q, :page, :type, :length, :sort, refine: [], unrefine:[])

    @query = params[:q] if (!(@query = params[:query]))
    @query = "*" if (@query and @query.length == 0)
    
    @query_proc = @query.dup if @query
    @query_proc = @query.gsub(/[^[:word:]\s\/\-\.\:\_\*\"]/, '') if @query_proc
  #  @query_proc = self.dates_to_lucene(@query_proc) if @query_proc
    
    @length = params[:length].to_i
    
    # Handle removal of filter
    if params[:unrefine] and session[:refine] and session[:refine]['_all']
        params[:unrefine].each do|u|
            ubits = u.split(/:/)
            
            if session[:refine]['_all'].has_key? ubits[0]
                session[:refine]['_all'][ubits[0]].select! do |a| 
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
    @query_proc = @query_proc.gsub(/on_display:["]*([A-Za-z]+)["]*/, 'on_display:YES') if @query_proc
    
    
	# Handle adding of refine filter
	@refine = {}
	if session[:last_search_query]  != @query
		session[:refine] = {}
	else 
		@refine = session[:refine] if session[:refine]
	end
	if params[:refine]
		@refine['_all'] = {} if @refine['_all'] == nil
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
			
			@refine['_all'][pbits[0]] = [] if !@refine['_all'].has_key? pbits[0]
			@refine['_all'][pbits[0]].push(p) if !@refine['_all'][pbits[0]].include? p
		}
		session[:refine] = @refine
		logger.info("refine" + @refine.to_s);
	end

	@refine['collection_object'] = @refine['_all']
    res = Resource::quicksearch(@query_proc, models: true, refine: @refine, page: @page, type: '_all', length: @length, lengthsByType: {'collection_object' => 20 }, sort: @sort, sortsByType: session[:sort], user: current_user)

	@result = res
	session[:last_search_query] = @query
	return
  end
end