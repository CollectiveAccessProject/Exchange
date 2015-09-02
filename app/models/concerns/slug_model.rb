module SlugModel
  extend ActiveSupport::Concern

  private

    def set_slug
      self.slug = self.title.parameterize
    end
end
