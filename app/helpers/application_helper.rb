module ApplicationHelper
  def media_size_for_version(version)
    case version
      when :icon
        return {width: 72, height: 72, full: false }
      when :thumbnail
        return {width: 200, height: 160, full: false }
      when :medium
        return {width: 400, height: 400, full: false }
      when :large
        return {width: 1000, height: 1000, full: false }
      when :full
        return {width: nil, height: nil, full: true }
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
