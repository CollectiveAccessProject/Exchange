module ApplicationHelper
  def media_size_for_version(version)
  	if Rails.application.config.x.media_sizes[version].nil?
  		raise ArgumentError, "Version #{version} is not valid"
  	else
  		return Rails.application.config.x.media_sizes[version]
  	end
  end

  def last_search_button(session, options=nil)
    if(session.key?(:last_search_type))
      text = (options && options.key?(:text)) ? options[:text] : "Back to search"
      cssClass = (options && options.key?(:class)) ? options[:class] : ""
      case session[:last_search_type]
        when 'quick'
          return  link_to(text, quick_search_url({"q" => session[:last_search_query]}), {class: cssClass})
        when 'advanced'
          return  link_to(text, advanced_search_url(session[:last_search_query_values]), {class: cssClass})
      end
      return ""
    end

  end

  def get_resource_view_path(resource, is_logged_in, collection_id=nil)
  	if(collection_id.nil?)
    	return is_logged_in ? resource_preview_path(resource) : resource_view_path(resource)
    else
    	return resource_view_from_collection_path(resource, collection_id)
    end
  end

  def get_file_icon(mimetype:, size:nil, image: nil, version:nil)
    size = 1 if(!size)
    size = size.to_s

    case
      when (((mimetype =~ /^application\/pdf$/)) && image && (defined? image.stored? && image.stored?)) && !version.nil?
        image_size = media_size_for_version(version)
        image_tag image.thumb(image_size[:area], format: 'png', frame: 0).convert("-background white -alpha remove").url
      when ((mimetype =~ /^image/) && image && (defined? image.stored? && image.stored?)) && !version.nil?
        image_size = media_size_for_version(version)
        image_tag image.thumb(image_size[:area], format: 'jpeg', frame: 0).url
      when ((mimetype == "application/vnd.ms-excel") || (mimetype == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
        "<div class='iconPadding'><i class=\"fa fa-file-excel-o fa-#{size}x\" aria-hidden=\"true\"></i></div>".html_safe
      when ((mimetype == "application/msword") || (mimetype == "application/vnd.openxmlformats-officedocument.wordprocessingml.document"))
        "<div class='iconPadding'><i class=\"fa fa-file-word-o fa-#{size}x\" aria-hidden=\"true\"></i></div>".html_safe
      when ((mimetype == "application/vnd.ms-powerpoint") || (mimetype== "application/vnd.openxmlformats-officedocument.presentationml.presentation"))
        "<div class='iconPadding'><i class=\"fa fa-file-powerpoint-o fa-#{size}x\" aria-hidden=\"true\"></i></div>".html_safe
      else
        "<div class='iconPadding'><i class=\"fa fa-file fa-#{size}x\" aria-hidden=\"true\"></i></div>".html_safe
    end
  end

  def get_role_for_display(r)
    roles_for_display = Rails.application.config.x.user_roles.select{ |k,v| (v == r.to_sym)}
    return (roles_for_display && roles_for_display.first && roles_for_display.first.first) ? roles_for_display.first.first : "???"
  end

  #
  #
  #
  def get_filters_for_query_builder(current_user=nil)

    # TODO: cache these values - we shouldn't hit Elastic every time
    # agg = Resource.search(
#         aggs: {
#             artist_types: { terms: { field: :artist_type}},
#            # place_types: { terms: { field: :place_type}},
#             #artist_nationality: { terms: { field: :artist_nationality}},
#             #classification: { terms: { field: :classification}},
#             medium: { terms: { field: :medium}},
#             #support: { terms: { field: :support}},
#             keywords: { terms: { field: :keyword}},
#             #style: { terms: { field: :style}}
#         }
#     )
# 
#     field_values = {}
#     agg.response['aggregations'].each do |aggname, v|
#       field_values[aggname] = []
#       v["buckets"].each do |k|
#         field_values[aggname].push(k['key'])
#       end
#     end

    affiliations = Rails.application.config.x.user_roles.invert

    if(current_user && (!current_user.has_role? :admin))
      affiliations.delete(:admin)
    end

    [
        {
            id: "affiliation",
            field: "affiliation",
            label: "Affiliation",
            type: "string",
            input: "select",
            values: affiliations
        }, 
        {
            id: "artist",
            field: "artist",
            label: "Artist name",
            type: "string"
        },
        {
            id: "artist_nationality",
            field: "artist_nationality",
            label: "Artist nationality",
            type: "string",
            input: "select",
            values: get_field_values('artist_nationality')
        },
        {
            id: "artist_type",
            field: "artist_type",
            label: "Artist type",
            type: "string",
            input: "text"
        },
        {
            id: "author",
            field: "author",
            label: "Author",
            type: "string"
        }, 
        {
            id: "collection_area",
            field: "collection_area",
            label: "Collection area",
            type: "string",
            input: "select",
            values: get_field_values('collection_area')
        },
        {
            id: "idno",
            field: "collection_identifier",
            label: "Collection object identifier",
            type: "string"
        },
        {
            id: "credit_line",
            field: "credit_line",
            label: "Credit line",
            type: "string"
        },
        {
            id: "date_created",
            field: "date_created",
            label: "Date created",
            type: "integer"
        },
        {
            id: "keyword",
            field: "terms",
            label: "Keyword",
            type: "string",
            input: "text"
        },
        {
            id: "label_copy",
            field: "label_copy",
            label: "Label copy",
            type: "string"
        },
        {
            id: "medium",
            field: "medium",
            label: "Medium",
            type: "string",
            input: "select",
            values: get_field_values('medium')
        },
        {
            id: "Classification",
            field: "classification",
            label: "Object classification",
            type: "string",
            input: "select",
            values: get_field_values('classification')
        },
        {
            id: "places",
            field: "places",
            label: "Place names",
            type: "string"
        },
        {
            id: "rating",
            field: "rating",
            label: "Rating",
            type: "integer"
        },
        {
            id: "style",
            field: "style",
            label: "Style or movement",
            type: "string",
            input: "select",
            values: get_field_values('style')
        },
        {
            id: "subject_matter",
            field: "subject_matter",
            label: "Subject matter",
            type: "string"
        },
        {
            id: "support",
            field: "support",
            label: "Support",
            type: "string",
            input: "select",
            values: get_field_values('support')
        },
        {
            id: "tag",
            field: "tag",
            label: "Tag",
            type: "string"
        },
        {
            id: "title",
            field: "title",
            label: "Title",
            type: "string"
        }
    ]
  end
end

#
# Generate IIIF path for media file. Options are passed as-is to Riiif::Engine.routes.url_helpers.image_path
#
def riiif_image_path(media_file, options=nil)
    begin
        return '' if !media_file.thumbnail.path
        Riiif::Engine.routes.url_helpers.image_path(media_file.thumbnail.path.gsub(/#{Rails.root}\/public\/system\/dragonfly\//, "").gsub("/", "|").gsub(".jpg", ""), options)
    rescue => e
        return ''
    end
end

def riiif_info_path(media_file, options=nil)
    begin
        return '' if !media_file.thumbnail.path
        Riiif::Engine.routes.url_helpers.info_path(media_file.thumbnail.path.gsub(/#{Rails.root}\/public\/system\/dragonfly\//, "").gsub("/", "|").gsub(".jpg", ""), options)
    rescue => e
        return ''
    end
end

def is_zoomable(media_file)
	case
		when (['LocalFile', 'FlickrLink'].include?(media_file.get_media_class(media_file.sourceable_type).to_s))
			if(media_file.thumbnail_uid != nil)
			    begin
				    return media_file if (media_file.thumbnail && media_file.thumbnail.mime_type.match(/^image\//))
				rescue
				    return false
				end
			end
			return false
		when (['CollectionobjectLink'].include?(media_file.get_media_class(media_file.sourceable_type).to_s))
			begin
				return media_file.sourceable.get_media
			rescue
				return false
			end
		else
			return false
	end
end

#
#
#
def get_current_locations_for_objects
    locations = []
    Resource.select(:location).distinct.order(:location).each do|l|
        next if (!l or !l.location or (l.location.length == 0))
        lp = l.location.split(/[ ]*➜[ ]*/)
        lpe = lp.select { |v| !v.match(/(Cabinet [\dA-Z]{1,3}|Shelf [\dA-Z]{1,3})/) }
        loc = lpe.join(" ➜ ")
        locations.push(loc) if !locations.include? loc
    end
    
    options_for_select([['All galleries', ' ']] + locations.map { |v| [v, v] } )
end

def get_field_values(f)
    return Rails.cache.read("field_values_" + f) if Rails.cache.exist? "field_values_" + f
    
    vals = []
    Resource.select(f).distinct.order(f).each do|l|
        next if (!l or !l[f] or (l[f].length == 0))
        vals.push(l[f])
    end
    
    if (f == 'classification') 
        Resource.select('additional_classification').distinct.order('additional_classification').each do|l|
            next if (!l or !l['additional_classification'] or (l['additional_classification'].length == 0))
            vals.push(l['additional_classification'])
        end
    end
    
    if (f == 'artist_nationality') or (f == 'style') 
        vals = vals.collect { |f| f.strip.split(/;/) }.flatten.select { |f| f.strip != '-'}.uniq.sort
    else
        vals = vals.collect { |f| f.strip.downcase.split(/;/) }.flatten.select { |f| f.strip != '-'}.uniq.sort
    end
    
    Rails.cache.write("field_values_" + f, vals)
    vals
end


def get_field_values_for_objects(f)
    vals = get_field_values(f)        
    opts = []
    vals.each do |v| 
        opts.push([v, v])
    end
    opts.unshift(['Any', ' '])

    options_for_select(opts)
end

def get_values_for_refine(field, query, type, refine_filters)
   # query.gsub!(/(?<=^|\s)([\d]+[A-Za-z0-9\.\/&\*]+)/, '"\1"')
    query.gsub!(/["]{2}/, '"')
    
    refine_q = ''
    if refine_filters and refine_filters[type] and (refine_filters[type].length > 0)
        refine_q = Resource::get_refine_facet_query(refine_filters, type)
    end
    agg = Resource.search(
        query: {
            simple_query_string:  {
                default_operator: "AND",
                query: '"' + query + '"' +  refine_q
            }
        },
        aggs: {
            values: { terms: { field: field, size: 50 } }
        }
    )
    
    acc = agg.response["aggregations"]["values"]["buckets"].map do |v|
    	v['key'] = v['key'].to_s
        next if !v['key'] or !v['key'].strip
        v['key']
    end  
    
    acc = acc.reduce([]) do |c,v|
    	t = v.split(';')
   		c.push(*t)
   	end
    
    sorted_acc = acc.uniq.sort
    
    return sorted_acc
end

def get_values_for_refine_for_select(field, query, type, refine_filters)
    vals = get_values_for_refine(field, query, type, refine_filters)        
    opts = [[' ', '']]
    vals.each do |v| 
        next if v and v.length == 0
        opts.push([v, v])
    end

    options_for_select(opts)
end

def get_values_for_refine_for_resource_type(field, query, refine_filters)
    vals = get_values_for_refine(field, query, nil, refine_filters)        
   # opts = [[' ', '']]
   #  resource_types = Resource.resource_types
#     vals.each do |v| 
#         next if v and v.length == 0
#         t = resource_types.key(v.to_i)
#         next if t.nil?
#         opts.push([t, v])
#     end
	opts = [
		[' ', ''],
		["Collection object", 3],
		["Resource", 1],
		["Learning collection", 2]
	]

    options_for_select(opts)
end


def format_refine_filters(refine_filters, type)
    return nil if (!refine_filters or !refine_filters[type])
    
    filter_display_names = Resource.quicksearch_refine_filter_names
    
    filters = []
    refine_filters[type].each do |k,l|
        l.each do |r|
            t = r.split(/:/)
            v = t[1]
            case
                when (t[0] == 'start_date')
                    if (t.length > 2)
                        e = r.split(/ AND /)
                        d_start = e[0].split(/:>=/)
                        d_end = e[1].split(/:<=/) 
                        v = d_start[1] + " - " + d_end[1]
                    elsif (d = t[1].match(/^([<=]+)/)) 
                        t[1].gsub!(/^[<=]+/, "")
                        v = "Before " + t[1]
                    else 
                        v = t[1]
                    end
                    filters.push({field: filter_display_names[t[0]], value: v, filter: r})
                when ((t[0] == 'end_date') and (d = t[1].match(/^([>=]+)/)))
                    t[1].gsub!(/^[>=]+/, "")
                    v = "After " + t[1]
                    filters.push({field: filter_display_names[t[0]], value: v, filter: r})
                when (t[0] == 'resource_type')
                	resource_types = Resource.resource_types
                	dv = resource_types.key(v.sub('"', '').to_i).to_s 
                
                	filters.push({field: filter_display_names[t[0]], value: dv, filter: r})
                else
                    v = Resource.quicksearch_refine_filter_display_value(t[0], t[1])
                    filters.push({field: filter_display_names[t[0]], value: v, filter: r})
            end
        end
    end
    filters
end
#
# Return array of groups owned by the specified user
# Param is a User instance (typically current_user)
#
def groups_for_user(user, options=nil)
	groups = Group.joins(:user_groups).where("user_groups.user_id = ? OR groups.user_id = ?", user.id, user.id).distinct.order("lower(groups.name)")

	opts = []
	groups.each do|g|
		if options and options[:ids]
			opts.push(g.id)
		else
			opts.push([g.name, g.id])
		end
	end

	opts
end



