namespace :exchange do
  desc 'Pulls in latest UMMA collections data from CollectiveAccess'
  task refresh_umma_collections_data: :environment do
    log = ActiveSupport::Logger.new('log/refresh_umma_collections_data.log')
    log.info "Task started at #{Time.now}"

    CollectiveAccess.set_credentials ENV['COLLECTIVEACCESS_USER'], ENV['COLLECTIVEACCESS_KEY']

    start = 0

    # query UMMA collections to get list of all records in chunks of 100 and
    # create or update exchange resources based on collectiveaccess_id
    begin
      log.info "Query CollectiveAccess simple service with start=#{start}"
      log.debug "Params are: hostname: #{ENV['COLLECTIVEACCESS_HOST']} url_root: #{ENV['COLLECTIVEACCESS_URL_ROOT']} port: #{ENV['COLLECTIVEACCESS_PORT']}"

      r = CollectiveAccess.simple  hostname: ENV['COLLECTIVEACCESS_HOST'],
                                   url_root: ENV['COLLECTIVEACCESS_URL_ROOT'],
                                   port: ENV['COLLECTIVEACCESS_PORT'].to_i,
                                   endpoint: 'exchangeObjectList',
                                   get_params: {
                                       q: '*',
                                       start: start,
                                       limit: 100,
                                       noCache: Rails.env.development? ? 1 : 0
                                   }

      log.info "Got response with size #{r.size}"

      r.each do |_, value|
        if value.is_a?(Hash) && value['collectiveaccess_id'].present?

          log.debug "Creating/Updating collectiveaccess_id #{value['collectiveaccess_id']}"

          Resource.where(collectiveaccess_id: value['collectiveaccess_id']).
              first_or_create.update title: value['title'],
                                     copyright_notes: value['copyright_notes'].present? ? value['copyright_notes'] : '',
                                     body_text: value['body_text'],
                                     subtitle: '',
                                     resource_type: 1,
                                     user_id: 1 # @todo: make configurable?
        end
      end

      start += 100

      if Rails.env.development? && start > 500
        break
      end

    end while r.size > 1

    log.info "Task finished at #{Time.now}"
  end
end
