module SlugModel
  extend ActiveSupport::Concern

    def set_slug
      if (self.has_attribute?(:title) && self.title)
        slug = self.title.parameterize
      elsif (self.has_attribute?(:caption) && self.caption)
        slug = self.caption.parameterize
      elsif (self.has_attribute?(:name) && self.name)
        slug = self.name.parameterize
      else
        slug = '???'
      end

      slug = self.class.name if (slug.length == 0)
      slug = slug[0..100]

      slug_stub = slug
      i = 1
      while(self.class.where(slug: slug).length > 0)
        slug = slug_stub + '-' + i.to_s
        i += 1
      end

      self.slug = slug
    end
end