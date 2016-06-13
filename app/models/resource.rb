class Resource < ActiveRecord::Base
  has_many :related_resources

  has_many :resources, through: 'related_resources', source: :related

  has_many :resource_hierarchies
  has_many :children, through: 'resource_hierarchies', source: :child_resource

  has_many :media_files, -> { order 'media_files.rank' }

  belongs_to :forked_from_resource, class_name: 'Resource', foreign_key: 'forked_from_resource_id'
  has_many :forked_resources, class_name: 'Resource', foreign_key: 'forked_from_resource_id'

  # this allows us to save related media files though the resource
  accepts_nested_attributes_for :media_files

  belongs_to :user

  serialize :indexing_data

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
  include RankModel
  before_create :set_slug
  after_create :set_rank

  # resource type constants
  RESOURCE = 1
  LEARNING_COLLECTION = 2
  COLLECTION = 2


  # get record as indexed json for elasticsearch
  def as_indexed_json(options={})
    # we want the indexing data at the "top level" of the document,
    # and not as sub-hash under the 'indexing-data' field
    record = as_json(except: [:indexing_data])
    if indexing_data.is_a? Hash
      record = record.merge(indexing_data)
    end
    record
  end


  # return true if resource type is "resource"
  def is_resource
    return self.resource_type == Resource::RESOURCE;
  end

  # return true if resource type is "collection"
  def is_collection
    return self.resource_type == Resource::LEARNING_COLLECTION;
  end

  # returns license type as text
  def get_license_type
    return Rails.application.config.x.license_types.key(self.copyright_license)
  end

  # return number of direct children on this resource
  # @param type Resource type to restrict count to (Resource::RESOURCE or Resource::LEARNING_COLLECTION); if omitted resources of all types are counted
  # @return int
  def child_count(type=nil)
    if ((type != Resource::RESOURCE) && (type != Resource::LEARNING_COLLECTION))
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
    s.key :media_formatting, :defaults => { :mode => :thumbnails }
    s.key :text_placement,  :defaults => { :placement => :above}
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

    matches = body_text_proc.to_enum(:scan, /&lt;media[ ]+([A-Za-z0-9_\-]+)[ ]*([A-Za-z]*)[ ]*(width=[\d]+)?[ ]*(height=[\d]+)?[ ]*(float=[A-Za-z]+)?&gt;/).map { Regexp.last_match }

    matches.each do |m|
      if (mf = MediaFile.where(:resource_id => self.id, :slug => m[1]).first)
        version = ((defined? m[2]) && m[2]) ? m[2] : 'thumbail'
        width = ((defined? m[3]) && m[3]) ? m[3].sub!("width=", "") : 160
        height = ((defined? m[4]) && m[4]) ? m[4].sub!("height=", "") : 120
        cssFloat = ((defined? m[5]) && m[5]) ? m[5].sub!("float=", "") : ""
        cssFloat.downcase!

        if ((cssFloat.downcase != 'left') && (cssFloat.downcase != 'right'))
          cssFloat = '';
        else
          cssFloat = "style=\"float: #{cssFloat}\""
        end
       body_text_proc.gsub!(m[0], "<div class=\"mediaEmbed\" #{cssFloat}>" + mf.sourceable.preview(version, width, height) + "<br/>" + mf.caption + "</div>")
      else
        body_text_proc.gsub!(m[0], "<div class=\"mediaEmbedError\" #{cssFloat}>Media with slug " + m[1] + " does not exist</div>")
      end
    end


    return body_text_proc
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