class Resource < ActiveRecord::Base
  belongs_to :parent, class_name: 'Resource', foreign_key: 'parent_id'
  has_many :child_resources, class_name: 'Resource', foreign_key: 'parent_id'

  has_many :related_resources
  has_many :resources, through: 'related_resources'
  has_many :media_files

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
  include Elasticsearch::Model::Callbacks

  # basic model validations
  validates :slug, uniqueness: 'Slug is already in use'
  validates :resource_type, :presence => true

  # slug handling
  include SlugModel
  before_create :set_slug

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