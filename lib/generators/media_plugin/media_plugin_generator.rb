class MediaPluginGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def generate_model
    generate :model, ARGV
  end

=begin
  def copy_views
    copy_file 'views/_form.html.erb', "app/views/media_plugins/_#{singular_table_name}_form.html.erb"
    copy_file 'views/_header.html.erb', "app/views/media_plugins/_#{singular_table_name}_header.html.erb"
    copy_file 'views/_preview.html.erb', "app/views/media_plugins/_#{singular_table_name}_preview.html.erb"
    copy_file 'views/_render.html.erb', "app/views/media_plugins/_#{singular_table_name}_render.html.erb"
  end

  def modify_model
    inject_into_file "app/models/#{singular_table_name}.rb", after: "ActiveRecord::Base\n" do <<-'RUBY'
  include MediaPluginModel
  has_one :media_file, as: :sourceable
    RUBY
    end

  end
=end

end
