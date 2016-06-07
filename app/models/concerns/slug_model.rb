module SlugModel
  extend ActiveSupport::Concern

  private

    def set_slug
      if (self.has_attribute?(:title) && self.title)
        slug = self.title.parameterize
      elsif (self.has_attribute?(:caption) && self.caption)
        slug = self.caption.parameterize
      else
        slug = '???'
      end

      slug = '???' if (slug.length == 0)

      slug_stub = slug
      i = 1
      while(self.class.where(slug: slug).length > 0)
        slug = slug_stub + '-' + i.to_s
        i += 1
      end

      self.slug = slug
    end
end