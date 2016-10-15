namespace :exchange do
	desc 'Create system user for import'
		task create_system_user: :environment do
			pass = Rails.env.development? ? 'michigan' : SecureRandom.hex
			User.where(email: 'admin@exchange.umma.umich.edu').first_or_create.update(
			name: 'UMMA Exchange', email: 'admin@exchange.umma.umich.edu',
		password: pass, password_confirmation: pass
		)
	end

	desc 'Pulls in latest UMMA collections data from CollectiveAccess'
		task refresh_umma_collections_data: :environment do
			log = ActiveSupport::Logger.new('log/refresh_umma_collections_data.log')
			log.info "Task started at #{Time.now}"

			CollectiveAccess.set_credentials ENV['COLLECTIVEACCESS_USER'], ENV['COLLECTIVEACCESS_KEY']

			user_id = User.where(email: 'admin@exchange.umma.umich.edu').first.id
			
			query = 'ca_objects.access_specific:exchange'		# CA query to use to pull relevant objects
			#query = 'ca_objects.idno:"2014" OR ca_objects.idno:"1954" OR ca_objects.idno:"2010" OR ca_objects.idno:"2010" OR ca_objects.idno:"1983" OR ca_objects.idno:"2014" OR ca_objects.idno:"2013" OR ca_objects.idno:"1988" OR ca_objects.idno:"2011" OR ca_objects.idno:"1998" OR ca_objects.idno:"2005" OR ca_objects.idno:"1997" OR ca_objects.idno:"1954" OR ca_objects.idno:"1961/1.170" OR ca_objects.idno:"2010/1.275" OR ca_objects.idno:"1983/1.248"'
			#query = 'ca_objects.idno:"2010/1.275" OR ca_objects.idno:"1983/1.248"'
			#query = 'ca_objects.idno:"2010/1.275" OR ca_objects.idno:"1983/1.248" OR ca_objects.idno:"1997/1.206" OR ca_objects.idno:"1954/1.536" OR ca_objects.idno:"2008/2.255" OR ca_objects.idno:"1993/2.13.1" OR ca_objects.idno:"2002/2.145" OR ca_objects.idno:"2000/2.158.1" OR ca_objects.idno:"1955/1.89" OR ca_objects.idno:"1949/1.199" OR ca_objects.idno:"1948/1.331"'


			start = 0
			limit = 100

			# query UMMA collections to get list of all records in chunks of 100 and
			# create or update exchange resources based on collectiveaccess_id
			begin
				log.info "Query CollectiveAccess simple services with start=#{start}"
				log.debug "Params are: hostname: #{ENV['COLLECTIVEACCESS_HOST']} url_root: #{ENV['COLLECTIVEACCESS_URL_ROOT']} port: #{ENV['COLLECTIVEACCESS_PORT']}"

				#puts "Params are: hostname: #{ENV['COLLECTIVEACCESS_HOST']} url_root: #{ENV['COLLECTIVEACCESS_URL_ROOT']} port: #{ENV['COLLECTIVEACCESS_PORT']}"

				# query exchangeObjectListForDisplay service
				puts "q=" + query
				object_list_for_display = CollectiveAccess.simple hostname: ENV['COLLECTIVEACCESS_HOST'],
					url_root: ENV['COLLECTIVEACCESS_URL_ROOT'],
					port: ENV['COLLECTIVEACCESS_PORT'].to_i,
					endpoint: 'exchangeObjectListForDisplay',
					get_params: {
						q: query,
						start: start,
						limit: limit,
						noCache: Rails.env.development? ? 1 : 0
					}

				log.info "Got response from 'exchangeObjectListForDisplay' with size #{object_list_for_display.size}"

				# add 'main' record data with hardcoded mapping
				object_list_for_display.each do |_, value|
					if value.is_a?(Hash) && value['collectiveaccess_id'].present?
						log.debug "Creating/Updating collectiveaccess_id #{value['collectiveaccess_id']}"
						puts  "Creating/Updating collectiveaccess_id #{value['collectiveaccess_id']}"

						if (Resource.where(collectiveaccess_id: value['collectiveaccess_id']).
							first_or_create.update(title: HTMLEntities.new.decode(value['title']),
							copyright_notes: value['copyright_notes'].present? ? HTMLEntities.new.decode(value['copyright_notes']) : '',
							body_text: HTMLEntities.new.decode(value['body_text']),
							subtitle: HTMLEntities.new.decode(value['subtitle']),
							resource_type: Resource::COLLECTION_OBJECT,
							collectiveaccess_id: value['collectiveaccess_id'],
							user_id: user_id))
							
							r = Resource.where(collectiveaccess_id: value['collectiveaccess_id']).first
				
							if (value['media'])
								sourceable_ids = r.media_files.select { |m| m.sourceable_type == 'CollectiveaccessLink' }.map { |a| a.sourceable_id}
								puts "MEDIA = " + value['title']
								
								i = 1;
								value['media'].split('|').each do |u|
									if ((key = /representation:([\d]+)/.match(u)))
									representation_id = key[1]

									m = nil
									if ((cl = CollectiveaccessLink.where(key: key.to_s, id: sourceable_ids).first) && cl.id)
										m = MediaFile.where(sourceable_id: cl.id, sourceable_type: 'CollectiveaccessLink').first
									end
									
									if (!m)
										m = MediaFile.new(title: key.to_s + ":" + i.to_s, caption: value['caption_text'], copyright_notes: '')
										m.save
									end

									m.set_sourceable_media({collectiveaccess_link: { original_link: u }})
									m.update({title: key.to_s + ":" + i.to_s, caption: value['caption_text'], access: 1, copyright_notes:i.to_s, resource_id: r.id})

									i += 1
								end
							end
						end
					end
				end
			end

			# query indexing data service
			object_list_for_search = CollectiveAccess.simple hostname: ENV['COLLECTIVEACCESS_HOST'],
				url_root: ENV['COLLECTIVEACCESS_URL_ROOT'],
				port: ENV['COLLECTIVEACCESS_PORT'].to_i,
				endpoint: 'exchangeObjectListForSearch',
				get_params: {
					q: query,
					start: start,
					limit: limit,
					noCache: Rails.env.development? ? 1 : 0
				}

			log.info "Got response with size #{object_list_for_search.size}"

			# add indexing data
			object_list_for_search.each do |_, value|
				if value.is_a?(Hash) && value['collectiveaccess_id'].present?
					log.debug "Creating/Updating collectiveaccess_id #{value['collectiveaccess_id']} for search"
					if (r = Resource.where(collectiveaccess_id: value['collectiveaccess_id']).first)
						puts "Creating/Updating collectiveaccess_id #{value['collectiveaccess_id']} for search"
						#puts value.inspect
						r.update(indexing_data: JSON.generate(value))
					end
				end
			end

			start += limit

			# only do one loop run in development. 100 test records.
			#if Rails.env.development?
			#	break
			#end

		end while object_list_for_display.size > 1

		log.info "Task finished at #{Time.now}"
	end

	desc 'Rebuild ElasticSearch quick search index'
		task :reindex => :environment do
			{'Resource' => 'resource', 'MediaFile' => 'media_file'}.each do |k,v|
			t = k.constantize

			index_name = t.index_name
			t.__elasticsearch__.create_index! force: true
			t.all.find_in_batches(batch_size: 1000) do |group|
			group_for_bulk = group.map do |a|
			{ index: { _id: a.id, data: a.as_indexed_json }}
			end

			t.__elasticsearch__.client.bulk(
			index: index_name,
			type: v,
			body: group_for_bulk
			)
			end
		end
	end

	desc 'Remove all resources and media from database'
		task :clean => :environment do
		MediaFile.new.external_media_classes do |c|
			t = c.constantize
			t.destroy_all
		end
		MediaFile.destroy_all
		CollectionobjectLink.destroy_all
		CollectiveaccessLink.destroy_all
		FlickrLink.destroy_all
		GoogledocsLink.destroy_all
		SoundcloudLink.destroy_all
		CollectionObjectLink.destroy_all
		VimeoLink.destroy_all
		YoutubeLink.destroy_all
		RelatedResource.destroy_all
		ResourceHierarchy.destroy_all
		#ResourceParent.destroy_all
		Tag.destroy_all
		Comment.destroy_all
		Favorite.destroy_all
		#Setting.destroy_all
		#Version.destroy_all
		Link.destroy_all
		Resource.destroy_all
	end

	desc 'Regenerate media previews'
		task rebuild_media_previews: :environment do
		media_files = MediaFile.all.each do|mf|

			if (!(defined? mf.thumbnail.url) || !mf.thumbnail.url || mf.thumbnail.url.include?("no_preview.png"))

			if (sourceable = mf.get_media_class(mf.sourceable_type))
				puts "No preview for " + mf.id.to_s + " " + mf.sourceable_type + "; reloading"
				begin
					instance = sourceable.find(mf.sourceable_id)

					instance.set_thumbnail if (instance && defined? instance.set_thumbnail)
					
					rescue
						puts "Could not load"
					end
				end
			end
    end
    end

	desc 'Add admin role to user with specified email address'
	task add_admin_to_user: :environment do
		 user_names = $ARGV.slice(1, ($ARGV.length) -1)

    user_names.each do |n|
      if (u = User.where(email: n).first)
				u.add_role :admin
        puts "[INFO] Added admin role to #{n}"
      else
        puts "[ERROR] No user found with email #{n}"
      end
    end

  end
end