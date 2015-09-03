class SimpleLink < MediaPlugin

  def self.init_from_settings(settings = {})
    SimpleLink.new
  end

  def self.header
    ActionController::Base.new.render_to_string 'media_plugins/simple_link_header'
  end

  # this could be a search form for youtube or soundcloud or just a textfield for a simple link
  def form
    ActionController::Base.new.render_to_string 'media_plugins/simple_link_form'
  end

  def to_json
    { foo: 'bar' }.to_json
  end

  # render this instance
  def render(options = {})
    ActionController::Base.new.render_to_string 'media_plugins/simple_link_render'
  end

end
