class Resource < ActiveRecord::Base
  rolify
  ratyrate_rateable "quality"

  has_many :related_resources, -> { order 'related_resources.rank' }, :dependent => :destroy
  has_many :collectionobject_links, :dependent => :destroy

  has_many :resources, through: 'related_resources', source: :related, :dependent => :destroy

  has_many :resource_hierarchies, -> { order 'resource_hierarchies.rank' },  :dependent => :destroy
  has_many :children, -> { order 'resource_hierarchies.rank' }, through: 'resource_hierarchies', source: :child_resource, :dependent => :destroy

  has_many :media_files, -> { order 'media_files.rank' },  :dependent => :destroy
  has_many :links, -> { order 'links.rank' }
  has_many :favorites

  has_many :resources_users, :dependent => :destroy
  has_many :resources_groups, :dependent => :destroy

  has_many :users, through: 'resources_users'
  belongs_to :users, class_name: 'User', foreign_key: 'author_id'

  has_many :resources_vocabulary_terms, class_name: 'ResourcesVocabularyTerm',  :dependent => :destroy
  has_many :vocabulary_terms, through: :resources_vocabulary_terms, class_name: 'VocabularyTerm'
  has_many :vocabulary_term_synonyms, through: :vocabulary_terms, class_name: 'VocabularyTermSynonym'

  has_many :collectionobject_links, through: 'media_files', source: 'sourceable', source_type: 'CollectionobjectLink'

  belongs_to :forked_from_resource, class_name: 'Resource', foreign_key: 'forked_from_resource_id'
  has_many :forked_resources, class_name: 'Resource', foreign_key: 'forked_from_resource_id'

  has_many :responses, -> { order 'resources.created_at DESC' }, class_name: 'Resource', foreign_key: 'in_response_to_resource_id'
  belongs_to :in_response_to, class_name: 'Resource', foreign_key: 'in_response_to_resource_id'

  # this allows us to save related media files though the resource
  accepts_nested_attributes_for :media_files

  belongs_to :user

  after_commit :update_search_index

  before_save :set_rating

  # resource type constants
  RESOURCE = 1
  LEARNING_COLLECTION = 2
  COLLECTION = 2
  COLLECTION_OBJECT = 3
  EXHIBITION = 4
  CRCSET = 5

  has_settings :class_name => 'ResourceSettingObject'  do |s|
    s.key :media_formatting, :defaults => { :mode => :slideshow }
    s.key :text_placement,  :defaults => { :placement => :below}
    s.key :text_formatting,  :defaults => { :show_all => 0, :collapse => 0 }
    s.key :user_interaction,  :defaults => { :allow_comments => 1, :allow_tags => 1, :allow_responses => 0, :display_responses_on_separate_page => 1 }
  end

  #
  #
  #
  @@settings_by_type = [
      {}, # not used
      {:media_formatting => [:mode], :text_placement => [:placement], :text_formatting => [:show_all, :collapse], :user_interaction => [:allow_comments, :allow_tags, :allow_responses, :display_responses_on_separate_page]}, # resources
      {:text_placement => [:placement], :user_interaction => [:allow_comments, :allow_tags, :allow_responses, :display_responses_on_separate_page]}, # collections
      {:media_formatting => [:mode]}, # collection objects
      {:media_formatting => [:mode]} # exhibitions
  ]

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
  #include Elasticsearch::Model::Callbacks



  # ElasticSearch mappings
  settings do
    mappings _all: {
        type: "string", analyzer: "english", search_analyzer: "english"
      }
    mappings dynamic: true do
      indexes :subtitle, type: 'string',analyzer: 'english'
      indexes :source, type: 'string',analyzer: 'english'
      indexes :copyright_notes, type: 'string',analyzer: 'english'
      indexes :location, type: 'string',analyzer: 'english'
      indexes :title, type: 'string', analyzer: 'english', fields: {
          raw: {
              type: 'string',
              index: 'not_analyzed'
          }
      }
      indexes :idno, type: 'string', analyzer: 'english', fields: {
          raw: {
              type: 'string',
              index: 'not_analyzed'
          }
      }
      indexes :artist, type: 'string', analyzer: 'english', fields: {
          raw: {
              type: 'string',
              index: 'not_analyzed'
          }
      }
      indexes :artist_nationality, type: 'string', analyzer: 'english', fields: {
          raw: {
              type: 'string',
              index: 'not_analyzed'
          }
      }
      indexes :author, type: 'string', analyzer: 'english', fields: {
          raw: {
              type: 'string',
              index: 'not_analyzed'
          }
      }
      indexes :medium, type: 'string', analyzer: 'english', fields: {
          raw: {
              type: 'string',
              index: 'not_analyzed'
          }
      }
      indexes :style, type: 'string', analyzer: 'english', fields: {
          raw: {
              type: 'string',
              index: 'not_analyzed'
          }
      }
      indexes :classification, type: 'string', analyzer: 'english', fields: {
          raw: {
              type: 'string',
              index: 'not_analyzed'
          }
      }
      indexes :collection_area, type: 'string', analyzer: 'english', fields: {
          raw: {
              type: 'string',
              index: 'not_analyzed'
          }
      }
      indexes :terms, type: 'string', analyzer: 'english', fields: {
          raw: {
              type: 'string',
              index: 'not_analyzed'
          }
      }
      indexes :affiliation, type: 'string', analyzer: 'english', fields: {
          raw: {
              type: 'string',
              index: 'not_analyzed'
          }
      }
      indexes :rating, type: 'integer'
      indexes :created_at, index: "not_analyzed", type: 'date'
      indexes :updated_at, index: "not_analyzed", type: 'date'
    end
  end


  # basic model validations
  validates :slug, uniqueness: 'Slug is already in use'
  validates :resource_type, :presence => true

  # slug handling
  include SlugModel
  before_validation  :set_slug

  #
  # Access control
  #
  def can(action, user)
    # owner/author/admin can do anything
    return true if (user && (user.has_role? :admin))
    return true if (user && (self.user_id == user.id))
    return true if (user && (self.author_id && (self.author_id == user.id)))

    # For now we allow public access to *ANY* collection object
    # regardess of how access is set, per JT's request
   return true if((self.is_collection_object) && (action == :view))

    # resource is publicly viewable
    if ((action == :view) && self.access > 0)
      return true
    end

    # is user in ACL?
    if (user && (f = ResourcesUser.where({resource_id: self.id, user_id: user.id}).first))
      case
        when ((action == :view) && (f.access >= 1))
          return true
        when ((action == :edit) && (f.access >= 2))
          return true
        else
          # noop
      end
    end

    # is user in group that has access to this resource?
    if (user && (f = ResourcesGroup.joins([:group, :user_groups]).where(resources_groups: {resource_id: self.id}, user_groups: {user_id: user.id}).first))
      case
        when ((action == :view) && (f.access >= 1))
          return true
        when ((action == :edit) && (f.access >= 2))     # includes groups admins (access = 3)
          return true
        else
          # noop
      end
    end

    return false
  end

  #
  # Search indexing
  #

  def index_for_search
    self.__elasticsearch__.index_document
  end
  def update_search_index
    self.__elasticsearch__.update_document
  end

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

    if (record['resource_type'].to_i == Resource::COLLECTION_OBJECT)
        record['on_display'] = record['on_display'] == 1 ? "1" : "0"
    end

    # pseudo fields
    record['author'] = [self.get_author_name(omit_email: true), self.get_author_name(omit_email: true, force_cataloguer: true), self.author_name]
    record['role'] = record['affiliation'] = self.roles.pluck("name")
   
    
    record['tag'] = self.tags.pluck("tag")
    record['keyword'] = self.vocabulary_terms.pluck("term") + self.vocabulary_term_synonyms.pluck("synonym")
    record['terms'] = (record['keywords'] ? record['keywords'].split(/\|/) : []) + record['keyword'] + record['tag']

    record['start_date'] = record['start_date'].to_i
    record['end_date'] = record['end_date'].to_i

    # Index ACL values
    # record['read_users'] = ResourcesUser.where({resource_id: self.id, access: 1}).pluck(:user_id)
#     record['edit_users'] = ResourcesUser.where({resource_id: self.id, access: 2}).pluck(:user_id)
#     record['read_groups'] = ResourcesGroup.where({resource_id: self.id, access: 1}).pluck(:group_id)
#     record['edit_groups'] = ResourcesGroup.where({resource_id: self.id, access: 2}).pluck(:group_id)

    # ActiveRecord is not able to see existing records once a new record is created. Is this due to the query cache?
    # Tried to disable the query cache in this context but it didn't make a difference. Using raw SQL works so that's
    # what we do, despite it being ugly

    record['read_users'] = []
    record['edit_users'] = []
    record['read_groups'] = []
    record['edit_groups'] = []

    recs = ActiveRecord::Base.connection.execute("SELECT user_id FROM resources_users WHERE resource_id = " + self.id.to_s + " AND access = 1")
    recs.each do |rec| 
        record['read_users'].push(rec[0].to_i)
    end
    recs = ActiveRecord::Base.connection.execute("SELECT user_id FROM resources_users WHERE resource_id = " + self.id.to_s + " AND access = 2")
    recs.each do |rec| 
        record['edit_users'].push(rec[0].to_i)
    end
    recs = ActiveRecord::Base.connection.execute("SELECT group_id FROM resources_groups WHERE resource_id = " + self.id.to_s + " AND access = 1")
    recs.each do |rec| 
        record['read_groups'].push(rec[0].to_i)
    end
    recs = ActiveRecord::Base.connection.execute("SELECT group_id FROM resources_groups WHERE resource_id = " + self.id.to_s + " AND access = 2")
    recs.each do |rec| 
        record['edit_groups'].push(rec[0].to_i)
    end
    
    # break out other date types
    other_date_regexp = Regexp.new("\\(([^\\)]+)\\)")
    if (m = other_date_regexp.match(record['other_dates']))
      record['other_date_types'] = m[1]
    end


    # index idno's of collection objects used as media
    collection_identifiers = []
    self.media_files.each do |m|
      if (m.sourceable.respond_to? (:get_collection_identifier))
        collection_identifiers.push(m.sourceable.get_collection_identifier)
      end
    end
    #puts collection_identifiers.inspect if (collection_identifiers.length > 0)
    record['related_collection_objects'] = collection_identifiers.join("; ")

    # index average rating for this resource
    record['rating'] = avg_rating.to_i

    record
  end
  serialize :indexing_data

  def set_rating
    score = self.avg_rating
    if (score != self.average_rating)
      self.average_rating = score
    end

    self.title_sort = ActionController::Base.helpers.strip_tags(self.title.strip)

  end

  # Generate display label for resource autocomplete
  def get_autocomplete_label
    label = ActionController::Base.helpers.strip_tags(self.title.strip)
    label += " (" + self.collection_identifier + ")" if (self.collection_identifier && self.collection_identifier.length > 0)
    label += " [COLLECTION]" if (self.is_collection)
    label += " [RESOURCE]" if (self.is_resource)
    label += " [EXHIBITION]" if (self.is_exhibition)
    label += " [STUDY SET]" if (self.is_crcset)

    label
  end


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

  # return true if type is for item-level "resource-y" behavior (eg. resource or collection object)
  def is_resource_like
    return (self.is_resource || self.is_collection_object)
  end

  # return true if type is for collection-level behavior (eg. collection or exhibition)
  def is_collection_like
    return (self.is_collection || self.is_exhibition)
  end

  def is_crcset
    return self.resource_type == Resource::CRCSET;
  end

  def is_response(parent_id)
    return self.in_response_to_resource_id == parent_id
  end

  def resource_type_for_display(plural=false)
    case self.resource_type
      when Resource::RESOURCE
        return plural ? "Resources" : "Resource"
      when Resource::COLLECTION_OBJECT
        return plural ? "Collection objects" : "Collection object"
      when Resource::COLLECTION
        return plural ? "Collections" : "Collection"
      when Resource::EXHIBITION
        return plural ? "Exhibitions" : "Exhibition"
      when Resource::CRCSET
        return plural ? "Study sets" : "Study set"
    end
  end

  def resource_type_as_sym()
    case self.resource_type
      when Resource::RESOURCE
        return :resources
      when Resource::COLLECTION_OBJECT
        return :collection_objects
      when Resource::COLLECTION
        return :collections
      when Resource::EXHIBITION
        return :exhibitions
      when Resource::CRCSET
        return :crcset
    end
  end
  
  # STATIC
  def self.resource_text_to_type(t)
    case t.downcase
      when 'resource', 'resources'
        return Resource::RESOURCE
      when 'collection_object', 'collection_objects'
        return Resource::COLLECTION_OBJECT
      when 'collection', 'collections'
        return Resource::COLLECTION
      when 'exhibition', 'exhibitions'
        return Resource::EXHIBITION
      when 'crcset', 'crcsets', 'crcset', 'crcsets'
        return Resource::CRCSET
    end
  end

  def self.is_favorite(user_id, resource_id)
    favs = Favorite.where({user_id: user_id, resource_id: resource_id})
    return (favs.count > 0) ? favs.first.id : false
  end

  def allow_responses
    if((self.settings(:user_interaction).allow_responses > 0) && (!self.is_collection_object))
      return true
    end

    false
  end

  # return list of settings valid for this type of resource
  def available_settings
    return @@settings_by_type[self.resource_type]
  end

  def setting_is_valid(group, setting=nil)
    if(!(@@settings_by_type[self.resource_type]))
      return false
    end
    if(!(@@settings_by_type[self.resource_type][group]))
      return false
    end
    if (setting == nil)
      return true
    end
    return @@settings_by_type[self.resource_type][group].include? setting
  end

  # returns license type as text
  def get_license_type
    return Rails.application.config.x.license_types.key(self.copyright_license)
  end

  def get_collection_object_field(f, options=nil)
    if (self.is_collection_object && indexing_data)
      indexing_data_hash = JSON.parse(indexing_data)

      val = indexing_data_hash[f]
      if (options && options.key?(:enclose_in_parens) && (options[:enclose_in_parens] == true) && (val) && (val.length > 0))
        val = "(" + val + ")"
      end
      return val
    end
  end

  #
  # Return collection of resources that reference the currently loaded one
  # via collectionobject_links
  #
  def get_collection_object_references
    # get ids of collection object links
    link_ids = CollectionobjectLink.where("resource_id = ?", self.id).pluck(:id)
    resource_ids = MediaFile.where("sourceable_id IN (?)", link_ids).pluck(:resource_id)

    #
    rel_resource_ids = RelatedResource.where("to_resource_id = ?", self.id).pluck(:resource_id)

    all_resource_ids = rel_resource_ids + resource_ids

    begin
        Resource.find(all_resource_ids)
    rescue
        return []
    end
  end

  #
  # Return list of Resources created by a single user
  # Either through the author_id or default user_id
  #
  def get_author_resources
    # Get the user and author ids for the current resource
    author = self.author_id
    user = self.user_id

    rel_resource_list = {}
    # If an author is assigned use that
    if author
      Resource.where('author_id=? OR user_id=?', author, author).find_each do |rel_resource|
        if rel_resource.id != self.id
          if rel_resource.author_id == author
            rel_resource_list[rel_resource.id] = rel_resource.title
          elsif rel_resource.author_id == nil and rel_resource.user_id == user
            rel_resource_list[rel_resource.id] = rel_resource.title
          end
        end
      end
      # If not, use the user who created the Resource
    else
      Resource.where('author_id=? OR user_id=?', user, user).find_each do |rel_resource|
        if rel_resource.id != self.id
          if rel_resource.author_id == user
            rel_resource_list[rel_resource.id] = rel_resource.title
          elsif rel_resource.author_id == nil and rel_resource.user_id == user
            rel_resource_list[rel_resource.id] = rel_resource.title
          end
        end
      end
    end
    return rel_resource_list
  end

  def sort_user_resources(access)
    @published_ids = Resource.where('access=? AND user_id=?', access, current_user.id).pluck(:id)
  end

  def get_responses
    response_ids = Resource.where(in_response_to_resource_id: self.id).pluck(:id)
    Resource.find(response_ids)
  end

  #
  # Get the count of collectionobject-based media files
  # Options:
  # :get_hidden = also count the hidden media files
  #
  def collectionobject_link_count(options = {})
    co_count = 0
    MediaFile.where('sourceable_type=? AND resource_id=?', 'collectionobjectLink', self.id).find_each do |rf|
      if rf.access == 1 and rf.display_collectionobject_link == 1
        co_count += 1
      elsif options[:get_hidden]
        co_count += 1
      end
    end
    return co_count
  end

  #
  # Get the Collection Object Resource pages for the sources
  # of the media files used in this Resource
  #
  def media_file_references
    mf_references = {}

    self.collectionobject_links.each do |co_link|
     begin
      co_resource = Resource.find(co_link.resource_id)

      MediaFile.where('sourceable_id=? AND resource_id=?', co_link.id, self.id).find_each do |media_resource|
        if media_resource.access == 1 and media_resource.display_collectionobject_link == 1
          mf_references[co_resource.id] = [co_resource.title, co_resource.collection_identifier]
        end
      end
      rescue => e
        # noop
      end
    end
    return mf_references
  end

  # return number of direct children on this resource
  # @param type Resource type to restrict count to (Resource::RESOURCE, Resource::LEARNING_COLLECTION, Resource::COLLECTION_OBJECT or Resource::EXHIBITION); if omitted resources of all types are counted
  # @return int
  def child_count(type=nil)
    if ((type != Resource::RESOURCE) && (type != Resource::LEARNING_COLLECTION) && (type != Resource::COLLECTION_OBJECT) && (type != Resource::EXHIBITION))
      type = nil
    end
    if (type == nil)
      responses = Resource.where("in_response_to_resource_id = ? AND response_banned_on IS ?", self.id, nil)
      return self.children.length - responses.length
    end

    # TODO: cache this
    r = ResourceHierarchy.joins(:child_resource).where("resources.resource_type = ? AND resource_hierarchies.resource_id = ?", type, self.id)
    return r.length
  end

  # Return list of parents for current resource
  def parents
    return Resource.joins(:resource_hierarchies).where("child_resource_id = ?", self.id)
  end

  # Return current author name
  #
  # Options:
  #   :omit_email = don't return email in addition to name
  def get_author_name(options = {})
    if(self.author_id && (!options || !options[:force_cataloguer]) && (u = User.find(self.author_id)))
      n = u.name
      n += " (" + u.email + ")"  if(!options || !options[:omit_email])
      return n
    end
    if (self.user_id)
      u = User.find(self.user_id)
      n = u.name
      n += " (" + u.email + ")"  if(!options || !options[:omit_email])
      return n
    end
    ""
  end

  def avg_rating
    array = Rate.where(rateable_id: self.id, rateable_type: 'Resource').where(dimension: "quality")
    stars = array.map {|r| r.stars }
    star_count = stars.count
    stars_total = stars.inject(0){|sum,x| sum + x }
    score = stars_total / (star_count.nonzero? || 1)
  end

  def total_ratings
    total = Rate.where(rateable_id: self.id).count
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

    matches = body_text_proc.to_enum(:scan, /&lt;media[ ]+([A-Za-z0-9_\-]+)[ ]*(version=\"[A-Za-z]*\")?[ ]*(width=\"[\d]+\")?[ ]*(height=\"[\d]+\")?[ ]*(caption=\"[A-Za-z]+\")?[ ]*(float=\"[A-Za-z]+\")?&gt;/).map { Regexp.last_match }

    matches.each do |m|
      if (mf = MediaFile.where(:resource_id => self.id, :slug => m[1]).first)
	if mf.access == 0
	  body_text_proc.gsub!(m[0], "")
	  next
        end
        version = (((defined? m[2]) && m[2]) ? m[2].sub!("version=", "").gsub!('"', "") : :thumbnail)
        width = ((defined? m[3]) && m[3]) ? m[3].sub!("width=", "").gsub!('"', "") : 160
        height = ((defined? m[4]) && m[4]) ? m[4].sub!("height=", "").gsub!('"', "") : 120
        caption = ((defined? m[5]) && m[5]) ? m[5].sub!("caption=", "").gsub!('"', "") : 'yes'
        cssFloat = ((defined? m[6]) && m[6]) ? m[6].sub!("float=", "").gsub!('"', "") : ""
        if (cssFloat)
          cssFloat.downcase!
        end
        case version
          when 'quarter'
            prev_version = 'medium'
            sizeClass = 'embedQuarter'
          when 'half'
            prev_version = 'large'
            sizeClass = 'embedHalf'
          when 'full'
            prev_version = 'large'
            sizeClass = 'embedFull'
          else
            prev_version = 'thumbnail'
        end
        if ((cssFloat.downcase != 'left') && (cssFloat.downcase != 'right'))
          cssFloat = '';
        else
          cssFloat = "style=\"float: #{cssFloat}\""
        end
        if caption == 'yes'
          caption_include = mf.caption
        else
          caption_include = ''
        end
        body_text_proc.gsub!(m[0], "<div class=\"mediaEmbed #{sizeClass}\" #{cssFloat}><a class=\"modalOpen\" href=\"#\" id=\"\link#{mf.sourceable.class.to_s}#{mf.sourceable.id.to_s}\" data-link-target=\"\##{mf.sourceable.class.to_s}#{mf.sourceable.id.to_s}Link\">" + mf.sourceable.preview(prev_version.to_sym, width, height, caption_include) + "</a></div>")
      else
        body_text_proc.gsub!(m[0], "<div class=\"mediaEmbedError\" #{cssFloat}>Media with slug " + m[1] + " does not exist</div>")
      end
    end


    return body_text_proc
  end




  #
  # Translate sort options to ElasticSearch sortable fields
  #
  def self.search_sort_for_type(sortsByType, type=nil)
    sort = sortsByType[type] if (type && sortsByType && sortsByType[type])

    case sort
      when "title"
        {field: "title.raw", direction: "asc" }
      when "idno"
        {field: "idno.raw", direction: "asc" }
      when "artist"
        {field: "artist.raw", direction: "asc"}
      when "created_at"
        {field: "created_at", direction: "desc" }
      when "start_date"
        {field: "start_date", direction: "asc" }
      when "rating"
        {field: "rating", direction: "desc" }
      else
        {field: "_score", direction: "desc" }
    end
  end
  
  
  def self.quicksearch_refine_filter_names
    return  {
        "artist" => "Artist/maker",
        "author" => "Author",
        "title" => "Title",
        "artist_nationality" => "Artist nationality",
        "start_date" => "Date created",
        "end_date" => "Date created",
        "style" => "Style",
        "medium" => "Medium",
        "on_display" => "On display?",
        "collection_area" => "Collection area",
        "classification" => "Classification",
        "terms" => "Keywords",
        "affiliation" => "Created for",
        "access" => "Access type",
        "rating" => "Avg visitor rating",
        "updated_at" => "Last update",
        "date_of_visit" => "Date of visit"
    }
  end
  
  
  def self.quicksearch_refine_filter_display_value(filter, value)
    value.gsub!(/"+/, "")
    case filter
        when "on_display"
            return (value.to_i > 0) ? "Yes" : "No"
        when "affiliation"
            if Rails.application.config.x.user_roles.invert.has_key? value.to_sym
                return Rails.application.config.x.user_roles.invert[value.to_sym]
            end
        when "access"
            if Rails.application.config.x.access_types.invert.has_key? value.to_i
                return Rails.application.config.x.access_types.invert[value.to_i]
            end
        when "rating"
            if value.to_i >= 1 and value.to_i <= 5
                return value + "+"
            end
        when "updated_at", "date_of_visit"
            m = value.match(/([\d]{4}-[\d]+-[\d]+)[ A-Za-z\-]+([\d]{4}-[\d]+-[\d]+)/)
            if m[1] == m[2]     # single date
                return m[1]
            elsif m[1] == '1900-01-01'  # before date
                return "Before " + m[2]
            elsif m[2] == '2100-01-01' # after date
                return "After " + m[1]
            else 
                return m[1] + " - " + m[2]
            end
    end
    value
  end

 
  # STATIC
  def self.get_refine_facet_query(refine, type, rewrite=true)
    acc = []
    if (refine[type] and (refine[type].length > 0)) 
        acc = []
        refine[type].each do |f,l|
            
            lproc = l.map {|r| r.gsub(/rating:([\d]+)/, '(rating:[\\1 TO 5])') } if rewrite
            acc.push("(" + lproc.join(" OR ") + ")") if lproc.length > 0
        end
    end 
    acc.join(" AND ")
  end
 
  # Simple "quicksearch" of resources (broken out by type)
  # STATIC
  def self.quicksearch(query, options={})
    query_proc = query.dup
    options[:page] = 1 if (!options[:page] || (options[:page] < 1))
    length = options[:length]
    length = WillPaginate.per_page if (!length)
	query_proc.gsub!(/author_id:([0-9]+)/, '(author_id:\1 OR user_id:\1)')
    
    # Quote parts of query that appear to be identifiers
    query_proc.gsub!(/(?<=^|\s)([\d]+[A-Za-z0-9\.\/\-&\*]+)/, '"\1"')
    query_proc.gsub!(/["]{2}/, '"')
    
    refine = options[:refine] ? options[:refine] : {}

    acl_str = ["access:1"]
    if(options[:user])
        if options[:user].has_role?(:admin)
            acl_str = ["access:[0 TO 1]"]
        else 
            acl_str.push("read_users:" + options[:user].id.to_s)
            acl_str.push("edit_users:" + options[:user].id.to_s)

            options[:user].groups.each do |g|
                acl_str.push("read_groups:" + g.id.to_s)
                acl_str.push("edit_groups:" + g.id.to_s)
            end
        end
    end

    if (!query_proc)
        query_proc = ''
    end

    if (!options[:type] || (options[:type] == 'resource'))
      begin
        resources_length = length
        resources_length = options[:lengthsByType]['resource'] if (options[:lengthsByType] && options[:lengthsByType]['resource'])

        sort = search_sort_for_type(options[:sortsByType], 'resource')
        
        refine_q = Resource::get_refine_facet_query(refine, 'resource')
        
        qdef = {
            query: {
                query_string:  {
                    default_operator: "AND",
                    query: "(" + query_proc + ") " + ((query_proc.length > 0) ? " AND " : "") + "resource_type:" + Resource::RESOURCE.to_s + " AND (" + acl_str.join(" OR ") + ")" + refine_q
                }
            }
        }
        qdef[:sort] = [{ sort[:field] => { order: sort[:direction]}}] if (sort)
        resources = Resource.search(qdef).per_page(resources_length)

        if (!options[:models])
          resources = resources.map do |r|
            if r._source
              { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type, access: r._source.access }
            end
          end
        else
          #options[:page] = 1 if resources.length/resources_length < options[:page]
          resources = resources.page(options[:page]).records
        end
      #rescue
        # no search?
       # resources = []
      end
    end


    if (!options[:type] || (options[:type] == 'collection'))
      begin
        collections_length = length
        collections_length = options[:lengthsByType]['collection'] if (options[:lengthsByType] && options[:lengthsByType]['collection'])

        sort = search_sort_for_type(options[:sortsByType], 'collection')
        
        refine_q = Resource::get_refine_facet_query(refine, 'collection')

        qdef = {
            query: {
                query_string:  {
                    default_operator: "AND",
                    query: "(" + query_proc + ") " + ((query_proc.length > 0) ? " AND " : "") + "resource_type:" + Resource::COLLECTION.to_s + " AND (" + acl_str.join(" OR ") + ")" + refine_q
                }
            }
        }
        qdef[:sort] = [{ sort[:field] => { order: sort[:direction]}}] if (sort)
        collections = Resource.search(qdef).per_page(collections_length)

        if(!options[:models])
          collections = collections.map do |r|
            if r._source
              { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type, access: r._source.access }
            end
          end
        else
          #options[:page] = 1 if collections.length/collections_length < options[:page]
          collections = collections.page(options[:page]).records
        end
      end
    end

    if (!options[:type] || (options[:type] == 'collection_object'))
      begin
        collection_objects_length = length
        collection_objects_length = options[:lengthsByType]['collection_object'] if (options[:lengthsByType] && options[:lengthsByType]['collection_object'])

        sort = search_sort_for_type(options[:sortsByType], 'collection_object')
        
        refine_q = Resource::get_refine_facet_query(refine, 'collection_object')
        
		# We don't check access on collection objects – they're all public no matter their settings
        qdef = {
            query: {
                query_string:  {
                    default_operator: "AND",
                    query: "(" + query_proc + ") " + ((query_proc.length > 0) ? " AND " : "") + "resource_type:" + Resource::COLLECTION_OBJECT.to_s + refine_q
                }
            }
        }
        qdef[:sort] = [{ sort[:field] => { order: sort[:direction]}}] if (sort)
        collection_objects = Resource.search(qdef).per_page(collection_objects_length)

        if (!options[:models])
          collection_objects = collection_objects.map do |r|
            if r._source
              { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type, access: r._source.access }
            end
          end
        else
          #options[:page] = 1 if collection_objects.length/collection_objects_length < options[:page]
          collection_objects = collection_objects.page(options[:page]).records
        end
      rescue
        # no search?
        collection_objects = []
      end
    end

    if (!options[:type] || (options[:type] == 'exhibition'))
      begin
        exhibitions_length = length
        exhibitions_length = options[:lengthsByType]['exhibition'] if (options[:lengthsByType] && options[:lengthsByType]['exhibition'])

        sort = search_sort_for_type(options[:sortsByType], 'exhibition')
        
        refine_q = Resource::get_refine_facet_query(refine, 'exhibition')

        qdef = {
            query: {
                query_string:  {
                    default_operator: "AND",
                    query: "(" + query_proc + ") " + ((query_proc.length > 0) ? " AND " : "") + "resource_type:" + Resource::EXHIBITION.to_s + " AND (" + acl_str.join(" OR ") + ")"
                }
            }
        }
        qdef[:sort] = [{ sort[:field] => { order: sort[:direction]}}] if (sort)
        
        exhibitions = Resource.search(qdef).per_page(exhibitions_length)

        if (!options[:models])
          exhibitions = exhibitions.map do |r|
            if r._source
              { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type, access: r._source.access }
            end
          end
        else
          #options[:page] = 1 if exhibitions.length/exhibitions_length < options[:page]
          exhibitions = exhibitions.page(options[:page]).records
        end
      rescue
        # no search?
        exhibitions = []
      end
    end

    if (!options[:type] || (options[:type] == 'crcset'))
      begin
        crcsets_length = length
        crcsets_length = options[:lengthsByType]['crcset'] if (options[:lengthsByType] && options[:lengthsByType]['crcset'])

        sort = search_sort_for_type(options[:sortsByType], 'crcset')
        
        refine_q = Resource::get_refine_facet_query(refine, 'crcset')

        qdef = {
            query: {
                query_string:  {
                    default_operator: "AND",
                    query: "(" + query_proc + ") " + ((query_proc.length > 0) ? " AND " : "") + "resource_type:" + Resource::CRCSET.to_s + " AND access:1" + refine_q
                }
            }
        }
        qdef[:sort] = [{ sort[:field] => { order: sort[:direction]}}] if (sort)
        crcsets = Resource.search(qdef).per_page(crcsets_length)

        if (!options[:models])
          crcsets = crcsets.map do |r|
            if r._source
              { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type, access: r._source.access }
            end
          end
        else
          #options[:page] = 1 if crcsets.length/crcsets_length < options[:page]
          crcsets = crcsets.page(options[:page]).records
        end
      rescue
        # no search?
        crcsets = []
      end
    end

    return {resources: resources, collections: collections, collection_objects: collection_objects, exhibitions: exhibitions, crcsets: crcsets}
  end

  # "Advanced" search of resources (broken out by type) and media files
  # STATIC
  def self.advancedsearch(params, options={})
    resource_type = params['type'].to_i

    length = options[:length]
    length = WillPaginate.per_page if (!length)

    query_elements = []
    query_elements_string = []  # used a pre-rewritten query
    query_display = []
    query_values = {'type' => resource_type }

    acl_str = ["access:1"]
    if(options[:user])
    	acl_str.push("read_users:" + options[:user].id.to_s)
    	acl_str.push("edit_users:" + options[:user].id.to_s)

    	options[:user].groups.each do |g|
    		acl_str.push("read_groups:" + g.id.to_s)
    		acl_str.push("edit_groups:" + g.id.to_s)
    	end
    end

    # basic fields
    if (params['keywords'] && (params['keywords'].length > 0))
      query_elements.push(params['keywords'])
      query_display.push("Keywords: " + params['keywords'])
      query_values['keywords'] = params['keywords']
    end
    {'title' => 'Title'}.each do |f, l|
      if (params[f] && (params[f].length > 0))
        v = params[f].gsub(/["']+/, '')
        query_elements.push(f + ':"' + v + '"')
        query_display.push(l + ": " +v)
        query_values[f] = v
      end
    end
    if (params['roles'] && (params['roles'].length > 0))
      params['roles'].each do |r|
        query_elements.push("role:\"#{r}\"")

        roles_for_display = Rails.application.config.x.user_roles.select{ |k,v| (v == r.to_sym)}
        role_for_display = (roles_for_display && roles_for_display.first && roles_for_display.first.first) ? roles_for_display.first.first : "???"
        query_display.push("Affiliation: " + role_for_display)
        query_values[r] = true
      end
    end

    if (params['min_rating'].to_i == 0) && (params['max_rating'].to_i == 5) 
        # noop
    else 
        if (params['min_rating'].to_i == params['max_rating'].to_i)
          d = v = params['min_rating']
        else
          v = '[' + params['min_rating'] + ' TO ' + params['max_rating'] + ']'
          d = "Between " + params['min_rating'] + ' and ' + params['max_rating']
        end

        query_elements.push('rating:' + v)
        query_display.push("Rating: " + d)
        query_values['rating'] = v
    end


    if (params['author_id'] && (params['author_id'].to_i > 0))
      query_elements.push("author_id:\"#{params['author_id'] }\"")

      begin
        u = User.find(params['author_id'])
        n = u.name

        query_display.push("Author: " + n)
        query_values['author_id'] = true
      rescue
        # noop
      end

    end
    
    query_elements_string = query_elements.dup

    case resource_type
      when Resource::RESOURCE
        # resource - no extra fields
      when Resource::COLLECTION
        # collection - no extra fields
      when Resource::COLLECTION_OBJECT
        # collection object
        {'collection_identifier' => 'Identifier', 'style' => 'Style, Group, Movement', 'collection_area' => 'Collection area', 'medium' => 'Medium', 'support' => 'Support', 'classification' => 'Classification/Object Type', 'additional_classification' => 'Additional classification/Object type', 'artist' => 'Artist/maker', 'artist_nationality' => 'Artist/Maker Nationality', 'credit_line' => 'Credit line',  'places' => 'Related places', 'on_display' => 'On display?', 'date_created' => 'Date created', 'other_dates' => 'Other dates', 'location' => 'Current location'}.each do |f, l|
          if (params[f] && (params[f].strip.length > 0))
            v = params[f].gsub(/["']+/, '')

            if (f == 'on_display')
                query_elements.push(f + ':' + (v ? "1" : "0"))
            elsif (f == 'date_created')
            
                m = /["]*([\d]+)["]*[ ]+(TO|-|–)[ ]+["]*([\d]+)["]*/i.match(v)
                if m
                    query_elements.push('start_date:>=' + m[1])
                    query_elements.push('end_date:<=' + m[3])
                else
                    query_elements.push('start_date:<=' + v)
                    query_elements.push('end_date:>=' + v)
                end
            else
                query_elements.push(f + ':"' + v + '"')
            end
            query_display.push(l + ":" +v)
            query_values[f] = v
            
            query_elements_string.push(f + ':"' + v + '"')
          end
        end
      when Resource::EXHIBITION
        # exhibition
        {'exhibition_artist' => 'Artist', 'exhibition_artist_nationality' => 'Artist nationality', 'exhibition_dates' => 'Exhibiton dates', 'exhibition_location' => 'Location'}.each do |f, l|
          if (params[f] && (params[f].strip.length > 0))
            v = params[f].gsub(/["']+/, '')
            query_elements.push(f + ':"' + v + '"')
            query_display.push(l + ":" +v)
            query_values[f] = v
            query_elements_string.push(f + ':"' + v + '"')
          end
        end
      else
        # no type
        resource_type = nil
    end
    # generate query
    query = query_elements.join(" AND ")
    query_for_display = query_display.join("; ")

    resources = []
    collections = []
    collection_objects = []
    exhibitions = []

    if ((resource_type == Resource::RESOURCE) || (resource_type.nil?))
      begin
        resources_length = length
        resources_length = options[:lengthsByType]['resource'] if (options[:lengthsByType] && options[:lengthsByType]['resource'])

        sort = search_sort_for_type(options[:sortsByType], 'resource')

        qdef = {
            query: {
                query_string:  {
                    query: query + " AND resource_type:" + Resource::RESOURCE.to_s + " AND (" + acl_str.join(" OR ") + ")"
                }
            }
        }
        qdef[:sort] = [{ sort[:field] => { order: sort[:direction]}}] if (sort)
        resources = Resource.search(qdef).per_page(resources_length)

        if (!options[:models])
          resources.map do |r|
            if r._source
              { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type, access: r._source.access }
            end
          end
        else
          resources = resources.page(options[:page]).records
        end

      rescue
        # no search?
        resources = options[:models] ?  nil : []
      end
    end

    if ((resource_type == Resource::COLLECTION) || (resource_type.nil?))
      collections_length = length
      collections_length = options[:lengthsByType]['collection'] if (options[:lengthsByType] && options[:lengthsByType]['collection'])

      begin
        sort = search_sort_for_type(options[:sortsByType], 'collection')

        qdef = {
            query: {
                query_string:  {
                    query: query + " AND resource_type:" + Resource::COLLECTION.to_s + " AND (" + acl_str.join(" OR ") + ")"
                }
            }
        }
        qdef[:sort] = [{ sort[:field] => { order: sort[:direction]}}] if (sort)
        collections = Resource.search(qdef).per_page(collections_length)

        if (!options[:models])
          collections.map do |r|
            if r._source
              { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type, access: r._source.access }
            end
          end
        else
          collections = collections.page(options[:page]).records
        end
      rescue
        # no search?
        collections = options[:models] ?  nil : []
      end
    end

    if ((resource_type == Resource::COLLECTION_OBJECT) || (resource_type.nil?))
      begin
        collection_objects_length = length
        collection_objects_length = options[:lengthsByType]['collection_object'] if (options[:lengthsByType] && options[:lengthsByType]['collection_object'])

        sort = search_sort_for_type(options[:sortsByType], 'collection_object')

        qdef = {
            query: {
                query_string:  {
                    query: query + " AND resource_type:" + Resource::COLLECTION_OBJECT.to_s
                }
            }
        }
        qdef[:sort] = [{ sort[:field] => { order: sort[:direction]}}] if (sort)
        collection_objects = Resource.search(qdef).per_page(collection_objects_length)

        if (!options[:models])
          collection_objects.map do |r|
            if r._source
              { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type, access: r._source.access }
            end
          end
        else
          collection_objects = collection_objects.page(options[:page]).records
        end
      rescue
        # no search?
        collection_objects = options[:models] ?  nil : []
      end
    end

    if ((resource_type == Resource::EXHIBITION) || (resource_type.nil?))
      exhibitions_length = length
      exhibitions_length = options[:lengthsByType]['exhibition'] if (options[:lengthsByType] && options[:lengthsByType]['exhibition'])

      begin
        sort = search_sort_for_type(options[:sortsByType], 'exhibition')

        qdef = {
            query: {
                query_string:  {
                    query: query + " AND resource_type:" + Resource::EXHIBITION.to_s + " AND (" + acl_str.join(" OR ") + ")"
                }
            }
        }
        qdef[:sort] = [{ sort[:field] => { order: sort[:direction]}}] if (sort)
        exhibitions = Resource.search(qdef).per_page(exhibitions_length)

        if (!options[:models])
          exhibitions.map do |r|
            if r._source
              { id: r._source.id, title: r._source.title, subtitle: r._source.subtitle, resource_type: r._source.resource_type, access: r._source.access }
            end
          end
        else
          exhibitions = exhibitions.page(options[:page]).records
        end
      rescue
        # no search?
        exhibitions = options[:models] ?  nil : []
      end
    end

    return {resources: resources, collections: collections, collection_objects: collection_objects, exhibitions: exhibitions, query_for_display: query_for_display, query_elements: query_elements, query_values: query_values, query: query, query_string: query_elements_string.join(" AND ")}
  end

  def destroy
    if (r = ResourceHierarchy.where(resource_id: self.id))
      r.each do |f|
        f.destroy
      end
    end

    if (r = ResourceHierarchy.where(child_resource_id: self.id))
      r.each do |f|
        f.destroy
      end
    end

    if self.children
      self.children.each do |f|
        f.destroy
      end
    end

    if self.related_resources
      self.related_resources do |f|
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
    if self.mode.present? && !([:thumbnails, :thumbnailsCaption, :slideshow, :embed].include? self.mode)
      raise StandardError, "Media formatting is invalid"
    end

    # text_placement / placement
    if self.placement.present? && !([:above, :below].include? self.placement)
      raise StandardError, "Text placement is invalid"
    end

    # text_formatting / show_all
    if self.show_all.present? && self.show_all != 0 && self.show_all != 1 && self.show_all != 2
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
