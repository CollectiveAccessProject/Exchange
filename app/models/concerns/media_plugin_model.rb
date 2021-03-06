module MediaPluginModel

  extend ActiveSupport::Concern

  module ClassMethods
    def header
      i = self.new
      i.action_view.render(
          partial: 'media_plugins/' + self.to_s.underscore + '_header'
      )
    end
  end

  def preview(version, width=nil, height=nil, caption=nil)
    unless self.id
      raise ArgumentError.new('Cannot render preview for empty model. You must load an existing record first.')
    end

    action_view.render(
      partial: 'media_plugins/' + self.class.to_s.underscore + '_preview',
      locals: { plugin_model: self, version: version, width: width, height: height, caption: caption}
    )
  end

  def render(version=nil, options=nil)
    version = :medium if (version.nil?)
    action_view.render(
        partial: 'media_plugins/' + self.class.to_s.underscore + '_render',
        locals: { plugin_model: self, version: version, options: options }
    )
  end

  def render_form
    action_view.render(
      partial: 'media_plugins/' + self.class.to_s.underscore + '_form',
      locals: { plugin_model: self }
    )
  end

  # get a new ActionView::Base object with everything
  # set so that we can render views from models
  # (which you're not supposed to do)
  def action_view
    action_view = ActionView::Base.new(Rails.configuration.paths['app/views'], {}, ActionController::Base.new)
    action_view.class_eval do
      include Rails.application.routes.url_helpers
      include ApplicationHelper

      def protect_against_forgery?
        false
      end
    end

    action_view
  end

end
