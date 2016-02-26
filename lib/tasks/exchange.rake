namespace :exchange do
  desc 'Pulls in latest UMMA collections data from CollectiveAccess'
  task refresh_umma_collections_data: :environment do
    CollectiveAccess.set_credentials ENV['COLLECTIVEACCESS_USER'], ENV['COLLECTIVEACCESS_KEY']
    r = CollectiveAccess.simple  hostname: ENV['COLLECTIVEACCESS_HOST'],
                                 url_root: ENV['COLLECTIVEACCESS_URL_ROOT'],
                                 port: ENV['COLLECTIVEACCESS_PORT'].to_i,
                                 endpoint: 'exchangeObjectList',
                                 get_params: {
                                     q: '*',
                                     start: 0,
                                     limit: 100,
                                     noCache: Rails.env.development? ? 1 : 0
                                 }
    r.each do |_, value|
      if value.is_a?(Hash) && value['collectiveaccess_id'].present?

        Resource.where(collectiveaccess_id: value['collectiveaccess_id']).
            first_or_create.update title: value['title'],
                                   copyright_notes: value['copyright_notes'].present? ? value['copyright_notes'] : '',
                                   body_text: value['body_text'],
                                   subtitle: '',
                                   resource_type: 1,
                                   user_id: 1 # @todo: make configurable?
      end
    end
  end
end
