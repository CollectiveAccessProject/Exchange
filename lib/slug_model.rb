module SlugModel
  def set_slug
    self.slug = self.title.parameterize
  end
end
