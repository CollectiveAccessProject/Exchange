class YoutubeLink < ActiveRecord::Base
  include MediaPluginModel
  has_one :media_file, as: :sourceable

  validates_with YoutubeLinkValidator
  before_save :extract_key_from_link

  def extract_key_from_link

    puts "In extract_key_from_link"
    puts "CHECKING FOR ERRORS: "
    puts self.errors


    if original_link

      # link shortener format
      if /youtu.be/.match(original_link)
        puts "MATCHED youtu.be"
        self.key = original_link.sub! 'https://youtu.be/', ''
      

      # embed link format
      elsif /embed/.match(original_link)
        puts "Matched embed"
        self.key = original_link.sub! 'https://www.youtube.com/embed/', ''

      # browser format
      elsif /\?v=/.match(original_link)
        puts "CGI PARSE"
        h = CGI::parse(URI::Parser.new.parse(original_link).query)
        self.key = h['v'].first
      else
        self.errors.add(:original_link, "Youtube URL format was unrecognizable")
      end

    end
  end

  def get_params
      return { :youtube_link => [:original_link]}
  end
end

