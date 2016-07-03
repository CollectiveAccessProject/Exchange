class FixCharSet < ActiveRecord::Migration
  def change
    execute "alter table collectiveaccess_links CONVERT TO CHARACTER SET utf8;"
    execute "alter table comments CONVERT TO CHARACTER SET utf8;"
    execute "alter table flickr_links CONVERT TO CHARACTER SET utf8;"
    execute "alter table googledocs_links CONVERT TO CHARACTER SET utf8;"
    execute "alter table groups CONVERT TO CHARACTER SET utf8;"
    execute "alter table indices CONVERT TO CHARACTER SET utf8;"
    execute "alter table local_files CONVERT TO CHARACTER SET utf8;"
    execute "alter table media_files CONVERT TO CHARACTER SET utf8;"
    execute "alter table related_resources CONVERT TO CHARACTER SET utf8;"
    execute "alter table resource_hierarchies CONVERT TO CHARACTER SET utf8;"
    execute "alter table resources CONVERT TO CHARACTER SET utf8;"
    execute "alter table schema_migrations CONVERT TO CHARACTER SET utf8;"
    execute "alter table settings CONVERT TO CHARACTER SET utf8;"
    execute "alter table soundcloud_links CONVERT TO CHARACTER SET utf8;"
    execute "alter table tags CONVERT TO CHARACTER SET utf8;"
    execute "alter table user_groups CONVERT TO CHARACTER SET utf8;"
    execute "alter table users CONVERT TO CHARACTER SET utf8;"
    execute "alter table versions CONVERT TO CHARACTER SET utf8;"
    execute "alter table vimeo_links CONVERT TO CHARACTER SET utf8;"
    execute "alter table youtube_links CONVERT TO CHARACTER SET utf8;"
  end
end
