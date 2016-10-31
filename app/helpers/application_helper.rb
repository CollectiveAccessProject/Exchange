module ApplicationHelper
  def media_size_for_version(version)
    case version
      when :icon
        return {width: 72, height: 72, area: "72x72" }
      when :thumbnail
        return {width: 240, height: 200, area: "240x200" }
      when :medium
        return {width: 400, height: 400, area: "400x400" }
      when :large
        return {width: 1000, height: 1000, area: "1000x1000" }
      when :huge
        return {width: 2000, height: 2000, area: "2000x2000" }
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
      when (((mimetype =~ /^image/) || (mimetype =~ /^application\/pdf$/)) && image && (defined? image.stored? && image.stored?)) && !version.nil?
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
end
