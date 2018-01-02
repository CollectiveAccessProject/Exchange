module ApplicationHelper
  def media_size_for_version(version)
    case version
      when :icon
        return {width: 72, height: 72, area: "72x72" }
      when :largeicon
        return {width: 120, height: 120, area: "120x120" }
      when :thumbnail
        return {width: 240, height: 200, area: "240x200" }
      when :medium
        return {width: 400, height: 400, area: "400x400" }
      when :large
        return {width: 1000, height: 1000, area: "1000x1000" }
      when :huge
        return {width: 2000, height: 2000, area: "2000x2000" }
      when :quarter
        return {width: '235', height: '235', area: '235x235'}
      else
        raise ArgumentError, "Version #{version} is not valid"
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

  def get_resource_view_path(resource, is_logged_in)
    return is_logged_in ? resource_preview_path(resource) : resource_view_path(resource)
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
        }, {
            id: "author",
            field: "author",
            label: "Author",
            type: "string"
        }, 
        {
            id: "keyword",
            field: "keyword",
            label: "Keyword",
            type: "string",
            input: "text"
        },
        {
            id: "tag",
            field: "tag",
            label: "Tag",
            type: "string"
        },
        {
            id: "idno",
            field: "collection_identifier",
            label: "Collection object identifier",
            type: "string"
        },
        {
            id: "title",
            field: "title",
            label: "Title",
            type: "string"
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
            id: "places",
            field: "places",
            label: "Place names",
            type: "string"
        },
        {
            id: "date_created",
            field: "date_created",
            label: "Date created",
            type: "integer"
        },
        {
            id: "credit_line",
            field: "credit_line",
            label: "Credit line",
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
            id: "support",
            field: "support",
            label: "Support",
            type: "string",
            input: "select",
            values: get_field_values('support')
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
            id: "style",
            field: "style",
            label: "Style or movement",
            type: "string",
            input: "select",
            values: get_field_values('style')
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
            id: "subject_matter",
            field: "subject_matter",
            label: "Subject matter",
            type: "string"
        },
        {
            id: "label_copy",
            field: "label_copy",
            label: "Label copy",
            type: "string"
        },
        {
            id: "rating",
            field: "rating",
            label: "Rating",
            type: "integer"
        }
    ]
  end
end

#
# Generate IIIF path for media file. Options are passed as-is to Riiif::Engine.routes.url_helpers.image_path
#
def riiif_image_path(media_file, options=nil)
  return '' if !media_file.thumbnail.path
  Riiif::Engine.routes.url_helpers.image_path(media_file.thumbnail.path.gsub(/#{Rails.root}\/public\/system\/dragonfly\//, "").gsub("/", "|").gsub(".jpg", ""), options)
end

def riiif_info_path(media_file, options=nil)
  return '' if !media_file.thumbnail.path
  Riiif::Engine.routes.url_helpers.info_path(media_file.thumbnail.path.gsub(/#{Rails.root}\/public\/system\/dragonfly\//, "").gsub("/", "|").gsub(".jpg", ""), options)
end

def is_zoomable(media_file)
	case
		when (['LocalFile', 'FlickrLink'].include?(media_file.get_media_class(media_file.sourceable_type).to_s))
			if(media_file.thumbnail_uid != nil)
				return media_file if (media_file.thumbnail && media_file.thumbnail.mime_type.match(/^image\//))
			end
			return false
		when (['CollectionobjectLink'].include?(media_file.get_media_class(media_file.sourceable_type).to_s))
			return media_file.sourceable.get_media
		else
			return false
	end
end

#
#
#
def get_current_locations_for_objects
    locs = []
    locs.push(['All galleries', ' '])
    Resource.select(:location).distinct.order(:location).each do|l|
        next if (!l or !l.location or (l.location.length == 0))
        locs.push([l.location, l.location])
    end

    options_for_select(locs)
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
    opts.unshift(['None', ' '])

    options_for_select(opts)
end
