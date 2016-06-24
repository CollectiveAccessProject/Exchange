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
end
