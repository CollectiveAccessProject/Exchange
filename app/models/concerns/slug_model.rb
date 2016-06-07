module SlugModel
  extend ActiveSupport::Concern

  private

    def set_slug
      self.slug = self.has_attribute?(:title) ? self.title.parameterize : self.caption.parameterize
    end
end