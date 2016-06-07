module SlugModel
  extend ActiveSupport::Concern

  private

    def set_slug
      self.slug = self.title.present? ? self.title.parameterize : self.caption.parameterize
    end
end