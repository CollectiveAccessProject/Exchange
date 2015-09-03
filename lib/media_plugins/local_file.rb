class LocalFile < MediaPlugin

  attr_accessor :media_file

  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::FormHelper
  include Rails.application.routes.url_helpers

  # LocalFile uses a MediaFile instance to initialize, not settings JSON
  def self.init_from_media_file(media_file)
    file = LocalFile.new
    file.media_file = media_file
    file
  end

  def self.header
    ActionController::Base.new.render_to_string 'media_plugins/local_file_header'
  end

  # this could be a search form for youtube or soundcloud or just a textfield for a simple link
  def form
    ActionController::Base.new.render_to_string template: 'media_plugins/local_file_form', locals: { media_file: media_file }
  end

  def to_json
    { foo: 'bar' }.to_json
  end

  # render this instance
  def render(options = {})
    ActionController::Base.new.render_to_string template: 'media_plugins/local_file_render', locals: { media_file: media_file }
  end

end
