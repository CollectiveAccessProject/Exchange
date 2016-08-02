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
end
