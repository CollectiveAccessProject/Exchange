class MediaPluginGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def copy_views
    copy_file 'views/_form.html.erb', "app/views/media_plugins/_#{singular_table_name}_form.html.erb"
    copy_file 'views/_header.html.erb', "app/views/media_plugins/_#{singular_table_name}_header.html.erb"
    copy_file 'views/_preview.html.erb', "app/views/media_plugins/_#{singular_table_name}_preview.html.erb"
    copy_file 'views/_render.html.erb', "app/views/media_plugins/_#{singular_table_name}_render.html.erb"
  end

  def modify_model
    generate :model, ARGV.join(' ')

    inject_into_file "app/models/#{singular_table_name}.rb", after: "ActiveRecord::Base\n" do <<-'RUBY'
  include MediaPluginModel
  has_one :media_file, as: :sourceable
    RUBY
    end
  end

  def add_to_media_file_list
    inject_into_file 'app/models/media_file.rb', after: 'LocalFile' do
      ", #{class_name}"
    end
  end

  def copy_and_edit_controller
    copy_file 'controller.rb', "app/controllers/#{plural_file_name}_controller.rb"
    gsub_file "app/controllers/#{plural_file_name}_controller.rb", 'ReplaceMe', class_name
    gsub_file "app/controllers/#{plural_file_name}_controller.rb", 'replace_me', singular_table_name
  end

  def add_route
    route "resources :#{plural_file_name}, except: [:index, :show, :new, :edit, :update, :destroy]"
  end

end
