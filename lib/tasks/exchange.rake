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

    start = 0

    # query UMMA collections to get list of all records in chunks of 100 and
    # create or update exchange resources based on collectiveaccess_id
    begin
      log.info "Query CollectiveAccess simple services with start=#{start}"
      log.debug "Params are: hostname: #{ENV['COLLECTIVEACCESS_HOST']} url_root: #{ENV['COLLECTIVEACCESS_URL_ROOT']} port: #{ENV['COLLECTIVEACCESS_PORT']}"
puts "Params are: hostname: #{ENV['COLLECTIVEACCESS_HOST']} url_root: #{ENV['COLLECTIVEACCESS_URL_ROOT']} port: #{ENV['COLLECTIVEACCESS_PORT']}"
      # query exchangeObjectListForDisplay service
      object_list_for_display = CollectiveAccess.simple hostname: ENV['COLLECTIVEACCESS_HOST'],
                                                        url_root: ENV['COLLECTIVEACCESS_URL_ROOT'],
                                                        port: ENV['COLLECTIVEACCESS_PORT'].to_i,
                                                        endpoint: 'exchangeObjectListForDisplay',
                                                        get_params: {
                                                            q: '*',
                                                            start: start,
                                                            limit: 100,
                                                            #noCache: Rails.env.development? ? 1 : 0
                                                        }
#puts object_list_for_display.inspect
      log.info "Got response from 'exchangeObjectListForDisplay' with size #{object_list_for_display.size}"

      # add 'main' record data with hardcoded mapping
      object_list_for_display.each do |_, value|
        if value.is_a?(Hash) && value['collectiveaccess_id'].present?

          log.debug "Creating/Updating collectiveaccess_id #{value['collectiveaccess_id']}"

          Resource.where(collectiveaccess_id: value['collectiveaccess_id']).
              first_or_create.update title: value['title'],
                                     copyright_notes: value['copyright_notes'].present? ? value['copyright_notes'] : '',
                                     body_text: value['body_text'],
                                     subtitle: '',
                                     resource_type: 1,
                                     user_id: User.where(email: 'admin@exchange.umma.umich.edu').first.id
        end
      end

      # query indexing data service
      object_list_for_search = CollectiveAccess.simple hostname: ENV['COLLECTIVEACCESS_HOST'],
                                                       url_root: ENV['COLLECTIVEACCESS_URL_ROOT'],
                                                       port: ENV['COLLECTIVEACCESS_PORT'].to_i,
                                                       endpoint: 'exchangeObjectListForSearch',
                                                       get_params: {
                                                           q: '*',
                                                           start: start,
                                                           limit: 100,
                                                           #noCache: Rails.env.development? ? 1 : 0
                                                       }

      log.info "Got response with size #{object_list_for_search.size}"

      # add indexing data
      object_list_for_search.each do |_, value|
        if value.is_a?(Hash) && value['collectiveaccess_id'].present?
          log.debug "Creating/Updating collectiveaccess_id #{value['collectiveaccess_id']} for search"
          Resource.where(collectiveaccess_id: value['collectiveaccess_id']).first.update(indexing_data: value)
        end
      end

      start += 100

      # only do one loop run in development. 100 test records.
      if Rails.env.development?
        break
      end

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
end
