class Resource < ActiveRecord::Base
  has_many :related_resources

  has_many :resources, through: 'related_resources', source: :related

  has_many :resource_hierarchies, -> { order 'resource_hierarchies.rank' }
  has_many :children, -> { order 'resource_hierarchies.rank' }, through: 'resource_hierarchies', source: :child_resource

  has_many :media_files, -> { order 'media_files.rank' }

  belongs_to :forked_from_resource, class_name: 'Resource', foreign_key: 'forked_from_resource_id'
  has_many :forked_resources, class_name: 'Resource', foreign_key: 'forked_from_resource_id'

  # this allows us to save related media files though the resource
  accepts_nested_attributes_for :media_files

  belongs_to :user


  # change log
  has_paper_trail

  # comments via gem
  acts_as_commentable

  # tags via custom module (@todo maybe rewrite as acts_as_* plugin)
  include TaggableModel

  # copyright instance methods
  include CopyrightModel

  # search (from elasticsearch gem)
  include Elasticsearch::Model

  # basic model validations
  validates :slug, uniqueness: 'Slug is already in use'
  validates :resource_type, :presence => true

  # slug handling
  include SlugModel
  before_validation  :set_slug

  # resource type constants
  RESOURCE = 1
  LEARNING_COLLECTION = 2
  COLLECTION = 2
  COLLECTION_OBJECT = 3
  EXHIBITION = 4


  #
  # Search indexing
  #

  # get record as indexed json for elasticsearch
  def as_indexed_json(options={})
    # we want the indexing data at the "top level" of the document,
    # and not as sub-hash under the 'indexing-data' field
    record = as_json(except: [:indexing_data])

    if (indexing_data)
      index_data_hash = JSON.parse(indexing_data)
      if index_data_hash.is_a? Hash
        record = record.merge(index_data_hash)
      end
    end
    record
  end
  serialize :indexing_data



  # return true if resource type is "resource"
  def is_resource
    return self.resource_type == Resource::RESOURCE;
  end

  # return true if resource type is "collection"
  def is_collection
    return self.resource_type == Resource::LEARNING_COLLECTION;
  end

  # return true if resource type is "collection object" (museum object imported from CA; acts as a resource)
  def is_collection_object
    return self.resource_type == Resource::COLLECTION_OBJECT;
  end

  # return true if resource type is "exhibition" (imported from CA; acts as a collection)
  def is_exhibition
    return self.resource_type == Resource::EXHIBITION;
  end


  # returns license type as text
  def get_license_type
    return Rails.application.config.x.license_types.key(self.copyright_license)
  end

  def get_collection_object_field(f, options=nil)
    if (self.is_collection_object)
      indexing_data_hash = JSON.parse(indexing_data)

      val = indexing_data_hash[f]
      if (options && options.key?(:enclose_in_parens) && (options[:enclose_in_parens] == true) && (val) && (val.length > 0))
        val = "(" + val + ")"
      end
      return val
    end
  end

  # return number of direct children on this resource
  # @param type Resource type to restrict count to (Resource::RESOURCE, Resource::LEARNING_COLLECTION, Resource::COLLECTION_OBJECT or Resource::EXHIBITION); if omitted resources of all types are counted
  # @return int
  def child_count(type=nil)
    if ((type != Resource::RESOURCE) && (type != Resource::LEARNING_COLLECTION) && (type != Resource::COLLECTION_OBJECT) && (type != Resource::EXHIBITION))
      type = nil
    end
    if (type == nil)
      return self.children.length
    end

    # TODO: cache this
    r = ResourceHierarchy.joins(:child_resource).where("resources.resource_type = ? AND resource_hierarchies.resource_id = ?", type, self.id)
    return r.length
  end

  # Return list of parents for current resource
  def parents
    return Resource.joins(:resource_hierarchies).where("child_resource_id = ?", self.id)
  end

  # the automatic elasticsearch callbacks seem to ignore or
  # overwrite the as_indexed_json, so we make our own callbacks
  # instead of including Elasticsearch::Model::Callbacks

  after_commit on: [:create] do
    __elasticsearch__.index_document
  end

  after_commit on: [:update] do
    __elasticsearch__.update_document
  end

  after_commit on: [:destroy] do
    __elasticsearch__.delete_document
  end

  # settings
  has_settings :class_name => 'ResourceSettingObject'  do |s|
    s.key :media_formatting, :defaults => { :mode => :slideshow }
    s.key :text_placement,  :defaults => { :placement => :below}
    s.key :text_formatting,  :defaults => { :show_all => 1, :collapse => 0 }
    s.key :user_interaction,  :defaults => { :allow_comments => 1, :allow_tags => 1, :allow_responses => 1, :display_responses_on_separate_page => 1 }
  end

  # configurable form drop-downs
  def self.resource_types
    Rails.application.config.x.resource_types
  end

  def self.access_types
    Rails.application.config.x.access_types
  end

  def to_s
    title
  end

  # Render body_text with parsed embedded media tags in the format
  # <media slug {version}>
  # where version is optional
  def parsed_body_text
    body_text_proc = self[:body_text]

    matches = body_text_proc.to_enum(:scan, /&lt;media[ ]+([A-Za-z0-9_\-]+)[ ]*(version=\"[A-Za-z]*\")?[ ]*(width=\"[\d]+\")?[ ]*(height=\"[\d]+\")?[ ]*(float=\"[A-Za-z]+\")?&gt;/).map { Regexp.last_match }

    matches.each do |m|
      if (mf = MediaFile.where(:resource_id => self.id, :slug => m[1]).first)
        version = (((defined? m[2]) && m[2]) ? m[2].sub!("version=", "").gsub!('"', "") : :thumbnail)
        width = ((defined? m[3]) && m[3]) ? m[3].sub!("width=", "").gsub!('"', "") : 160
        height = ((defined? m[4]) && m[4]) ? m[4].sub!("height=", "").gsub!('"', "") : 120
        cssFloat = ((defined? m[5]) && m[5]) ? m[5].sub!("float=", "").gsub!('"', "") : ""
        if (cssFloat)
          cssFloat.downcase!
        end

        if ((cssFloat.downcase != 'left') && (cssFloat.downcase != 'right'))
          cssFloat = '';
        else
          cssFloat = "style=\"float: #{cssFloat}\""
        end
        body_text_proc.gsub!(m[0], "<div class=\"mediaEmbed\" #{cssFloat}>" + mf.sourceable.preview(version.to_sym, width, height) + "<br/>" + mf.caption + "</div>")
      else
        body_text_proc.gsub!(m[0], "<div class=\"mediaEmbedError\" #{cssFloat}>Media with slug " + m[1] + " does not exist</div>")
      end
    end


    return body_text_proc
  end

  # Simple "quicksearch" of resources (broken out by type)
  # STATIC
  def self.quicksearch(query)
    begin
      resources = Resource.search(query + " AND resource_type:" + Resource::RESOURCE.to_s).map do |r|
        if r._source
          { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type }
        end
      end

    rescue
      # no search?
      resources = []
    end

    begin
      collections = Resource.search(query + " AND resource_type:" + Resource::COLLECTION.to_s).map do |r|
        if r._source
          { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type }
        end
      end
    rescue
      # no search?
      collections = []
    end

    begin
      collection_objects = Resource.search(query + " AND resource_type:" + Resource::COLLECTION_OBJECT.to_s).map do |r|
        if r._source
          { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type }
        end
      end
    rescue
      # no search?
      collection_objects = []
    end

    begin
      exhibitions = Resource.search(query + " AND resource_type:" + Resource::EXHIBITION.to_s).map do |r|
        if r._source
          { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type }
        end
      end
    rescue
      # no search?
      exhibitions = []
    end

    return {resources: resources, collections: collections, collection_objects: collection_objects, exhibitions: exhibitions}
  end

  # "Advanced" search of resources (broken out by type) and media files
  # STATIC
  def self.advancedsearch(params)
    resource_type = params['type'].to_i

    query_elements = []

    # basic fields
    if (params['keywords'] && (params['keywords'].length > 0))
      query_elements.push(params['keywords'])
    end
    ['title'].each do |f|
      if (params[f] && (params[f].length > 0))
      query_elements.push(f + ':"' + params[f].gsub(/["']+/, '') + '"')
      end
    end

    case resource_type
      when Resource::RESOURCE
        # resource - no extra fields
      when Resource::COLLECTION
        # collection - no extra fields
      when Resource::COLLECTION_OBJECT
        # collection object
        ['style', 'medium', 'classification', 'additional_classification', 'artist', 'artist_nationality', 'credit_line',  'places', 'on_display', 'date_created', 'other_dates', 'current_location'].each do |f|
          if (params[f] && (params[f].length > 0))
            query_elements.push(f + ':"' + params[f].gsub(/["']+/, '') + '"')
          end
        end
      when Resource::EXHIBITION
        # exhibition
      else
        # no type
        resource_type = nil
    end
    # generate query
    query = query_elements.join(" AND ")
puts "QUERY IS " + query

    resources = []
    collections = []
    collection_objects = []
    exhibitions = []

    if ((resource_type == Resource::RESOURCE) || (resource_type.nil?))
      begin
        resources = Resource.search(query + " AND resource_type:" + Resource::RESOURCE.to_s).map do |r|
          if r._source
            { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type }
          end
        end

      rescue
        # no search?
      end
    end

    if ((resource_type == Resource::COLLECTION) || (resource_type.nil?))
      begin
        collections = Resource.search(query + " AND resource_type:" + Resource::COLLECTION.to_s).map do |r|
          if r._source
            { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type }
          end
        end
      rescue
        # no search?
      end
    end

    if ((resource_type == Resource::COLLECTION_OBJECT) || (resource_type.nil?))
      begin
        collection_objects = Resource.search(query + " AND resource_type:" + Resource::COLLECTION_OBJECT.to_s).map do |r|
          if r._source
            { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type }
          end
        end
      rescue
        # no search?
      end
    end

    if ((resource_type == Resource::EXHIBITION) || (resource_type.nil?))
      begin
        exhibitions = Resource.search(query + " AND resource_type:" + Resource::EXHIBITION.to_s).map do |r|
          if r._source
            { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type }
          end
        end
      rescue
        # no search?
      end
    end

    return {resources: resources, collections: collections, collection_objects: collection_objects, exhibitions: exhibitions}
  end


  def destroy
    if media_files
      media_files.each do |f|
        f.destroy
      end
    end

    super
  end
end

# validators for resource settings
class ResourceSettingObject < RailsSettings::SettingObject
  validate do
    # media_formatting / mode
    if self.mode.present? && !([:thumbnails, :slideshow, :embed].include? self.mode)
      raise StandardError, "Media formatting is invalid"
    end

    # text_placement / placement
    if self.placement.present? && !([:above, :below].include? self.placement)
      raise StandardError, "Text placement is invalid"
    end

    # text_formatting / show_all
    if self.show_all.present? && self.show_all != 0 && self.show_all != 1
      raise StandardError, "Text formatting show all setting is invalid"
    end

    # text_formatting / collapse
    if self.collapse.present? && self.collapse != 0 && self.collapse != 1
      raise StandardError, "Text formatting collapse setting is invalid"
    end

    # user_interaction / allow comments
    if self.allow_comments.present? && self.allow_comments != 0 && self.allow_comments != 1
      raise StandardError, "User interaction allow comments setting is invalid"
    end

    # user_interaction / allow tags
    if self.allow_tags.present? && self.allow_tags != 0 && self.allow_tags != 1
      raise StandardError, "User interaction allow tags setting is invalid"
    end

    # user_interaction / allow tags
    if self.allow_responses.present? && self.allow_responses != 0 && self.allow_responses != 1
      raise StandardError, "User interaction allow responses setting is invalid"
    end

    # user_interaction / display_responses_on_separate_page
    if self.display_responses_on_separate_page.present? && self.display_responses_on_separate_page != 0 && self.display_responses_on_separate_page != 1
      raise StandardError, "User interaction display_responses_on_separate_page setting is invalid"
    end
  end
end