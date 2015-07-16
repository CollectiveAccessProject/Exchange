module SlugModel
  extend ActiveSupport::Concern

  def set_slug
    self.slug = self.title.parameterize
  end
end
