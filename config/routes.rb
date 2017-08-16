Rails.application.routes.draw do
  post '/rate' => 'rater#create', :as => 'rate'
  devise_for :users, :controllers => {
        omniauth_callbacks: 'users/omniauth_callbacks',
        sessions: 'users/sessions',
        registrations: 'users/registrations'
  }

  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session_path
  end

  root 'welcome#index'

  resources :resources


  resources :groups
  get '/groups/:id/autocomplete_group_user_name' => 'groups#autocomplete_user_name', as: 'autocomplete_group_user_name'
  post '/groups/:id/add_group_user' => 'groups#add_user', as: 'group_add_user'
  get '/groups/:id/remove_group_user' => 'groups#remove_user', as: 'group_remove_user'


  # add user guide and other pages in About
  get '/user_guide' => 'about#user_guide'

  # add new collection - just a resource with the resource_type preset
  get '/collections/new' => 'resources#new', type: 'collection', as: "new_collection"
  get '/collections/new/child_id/:child_id' => 'resources#new', type: 'collection', as: "new_collection_with_id"
  get '/collections/new/subcollection/:parent_id' => "resources#new", type: 'collection', as: "new_subcollection_with_id"

  # add new resource to collection
  get '/resources/new/collection/:parent_id' => "resources#new", type: 'resource', as: "new_resource_for_collection_with_id"

  # add new CRC set
  get '/crc/new' => 'resources#new', type: 'crcset', as: "new_crcset"


  # media files only exist in resource context, so we basically only need create, update and delete
  # @todo: implement update
  resources :media_files, except: [:index, :show, :new, :edit]

  # same goes for media plugin implementations. they can't exist without media_file and resource
  resources :local_files, except: [:index, :show, :new, :edit, :update, :destroy]
  resources :youtube_links, except: [:index, :show, :new, :edit, :update, :destroy]
  resources :soundcloud_links, except: [:index, :show, :new, :edit, :update, :destroy]
  resources :vimeo_links, except: [:index, :show, :new, :edit, :update, :destroy]
  resources :flickr_links, except: [:index, :show, :new, :edit, :update, :destroy]
  resources :googledocs_links, except: [:index, :show, :new, :edit, :update, :destroy]

  resources :resource_hierarchies

  # test for adding comments and tags asynchronously
  match '/resources/add_comment' => 'resources#add_comment', :as => 'add_new_comment_to_resources', :via => [:post]
  match '/resources/add_tag' => 'resources#add_tag', :as => 'add_new_tag_to_resources', :via => [:post]
  match '/resources/add_term' => 'resources#add_term', :as => 'add_new_term_to_resources', :via => [:post]
  match '/resources/add_link' => 'resources#add_link', :as => 'add_new_link_to_resources', :via => [:post]
  match '/resources/:id/remove_comment' => 'resources#remove_comment', :as => 'remove_comment_from_resources', :via => [:get]
  match '/resources/:id/remove_tag' => 'resources#remove_tag', :as => 'remove_tag_from_resources', :via => [:get]
  match '/resources/:id/remove_term' => 'resources#remove_term', :as => 'remove_term_from_resources', :via => [:get]
  match '/resources/:id/remove_link' => 'resources#remove_link', :as => 'remove_link_from_resources', :via => [:get]
  match '/resources/:id/remove_parent/:parent_id' => 'resources#remove_parent', :as => 'remove_parent', :via => [:get]

  match '/resources/edit_link/:link_id' => 'resources#edit_link', :via => [:put]
  match '/resources/edit_link_caption/:link_id' => 'resources#edit_link_caption', :via => [:put]


  post '/resources/:id/set_parent' => 'resources#update', as: "set_resource_parent_with_id"
  post '/resources/:id/add_related_resource' => 'resources#add_related_resource', as: "add_related_resource"
  match '/resources/edit_related_resource_caption/:related_id' => 'resources#edit_related_resource_caption', :via => [:put]


 # TODO: make this POST
  get '/resources/:id/remove_related_resource' => 'resources#remove_related_resource', as: "remove_related_resource"
  post '/resources/:id/fork' => 'resources#fork', as: "fork_resource"
  post '/resources/:id/publish' => 'resources#toggle_access', as: "publish_resource"
  post '/resources/:id/set_response_info/:response_id' => 'resources#set_response_info', as:"set_response_info"


  post '/resources/:id/add_child_resource' => 'resources#add_child_resource', as: "add_child_resource"
  post '/resources/:id/add_child_resources' => 'resources#add_child_resources', as: "add_child_resources"

  get '/resources/:id/set_media_order' => 'resources#set_media_order', as: "set_media_order"
  get '/resources/:id/set_resource_order' => 'resources#set_resource_order', as: "set_resource_order"
  get '/resources/:id/set_link_order' => 'resources#set_link_order', as: "set_link_order"
  get '/resources/:id/set_related_resource_order' => 'resources#set_related_resource_order', as: "set_related_resource_order"

  get '/resources/:id/get_media_list/:start' => 'resources#get_media_list', as: "get_media_list"

  # save preferences via ajax, get JSON in return
  post '/resources/:id/save_preferences' => 'resources#save_preferences',  defaults: { format: 'json' }

  get '/resources/:id' => 'resources#show', mode: :preview,  as: 'resource_preview'
  get '/resources/:id/view' => 'resources#view',  as: 'resource_view'
  
  get '/quick_search/query' => 'quick_search#query', as: 'quick_search'
  get '/advanced_search/query' => 'quick_search#advanced', as: 'advanced_search'
  get '/quick_search/query_results/:type/:page/*query' => 'quick_search#query_results', as: 'query_results', constraints: { :query => /.+/ }
  get '/quick_search/autocomplete_collection_title' => 'quick_search#autocomplete_resource_title', mode: Resource::COLLECTION, as: 'quick_search_autocomplete_resource_title'
  get '/quick_search/autocomplete_collection_resource_title' => 'quick_search#autocomplete_resource_title', mode: Resource::RESOURCE, as: 'quick_search_autocomplete_collection_resource_title'

  get '/dashboard' => 'dashboard#index', as: 'dashboard'

  get '/resources/:id/autocomplete_resource_title' => 'resources#autocomplete_resource_title', mode: Resource::RESOURCE, as: 'autocomplete_resource_title'
  get '/resources/:id/autocomplete_collection_object_title' => 'resources#autocomplete_resource_title', mode: Resource::COLLECTION_OBJECT, as: 'autocomplete_collection_object_title'
  get '/resources/:id/autocomplete_user_name' => 'resources#autocomplete_user_name', as: 'autocomplete_user_name'
  get '/resources/:id/autocomplete_vocabulary_term_term' => 'resources#autocomplete_vocabulary_term_term', as: 'autocomplete_vocabulary_term_term'
  get '/resources/:id/autocomplete_current_location' => 'resources#autocomplete_current_location', as: 'autocomplete_current_location'
  get '/resources/:id/autocomplete_author' => 'resources#autocomplete_author', as: 'autocomplete_author'


  # resource user access list
  post '/resources/:id/add_user_access' => 'resources#add_user_access', as: "add_user_access"
  # TODO: make this POST
  get '/resources/:id/remove_resource_user_access' => 'resources#remove_user_access', as: "remove_resource_user_access"

  # resource group access list
  post '/resources/:id/add_group_access' => 'resources#add_group_access', as: "add_group_access"
  # TODO: make this POST
  get '/resources/:id/remove_resource_group_access' => 'resources#remove_group_access', as: "remove_resource_group_access"


  get '/featured' => 'featured#index', as: 'featured'
  get '/featured/:slug' => 'featured#index', as: 'featured_load_feature'
  get '/featured/:id/get_set_contents' => 'featured#get_set_contents', as: 'featured_get_set_contents'
  get '/featured/:slug/get' => 'featured#get_set_contents', as: 'featured_get_set_contents_by_slug'

  post '/favorites/:id/add' => 'favorites#add', as: 'add_favorite'
  post '/favorites/:id/remove' => 'favorites#remove', as: 'remove_favorite'


  # user admin
  get '/users/:id' => 'users#edit'
  resources :users

  # featured sets admin
  get '/featured_content_sets' => 'featured_content_sets#index'
  get '/featured_content_sets/set_order' => 'featured_content_sets#set_order'
  resources :featured_content_sets
  resources :featured_content_set_items

  get '/featured_content_sets/:id/autocomplete_resource_title' => 'featured_content_sets#autocomplete_resource_title', mode: Resource::RESOURCE, as: 'autocomplete_set_resource_title'
  post '/featured_content_sets/:id/add_set_item' => 'featured_content_sets#add_set_item', as: 'featured_content_sets_add_set_item'
  get '/featured_content_sets/:id/remove_set_item' => 'featured_content_sets#remove_set_item', as: 'featured_content_sets_remove_set_item'
  get '/featured_content_sets/:id/set_item_order' => 'featured_content_sets#set_item_order'

  # vocabulary terms
  get '/vocabulary_terms' => 'vocabulary_terms#index'
  resources :vocabulary_terms
  resources :vocabulary_term_synonyms
  get '/vocabulary_terms/:id/add_child' => 'vocabulary_terms#new', as: 'vocabulary_terms_add_child'
  post '/vocabulary_terms/:id/add_synonym' => 'vocabulary_terms#add_synonym', as: 'vocabulary_terms_add_synonym'
  patch '/vocabulary_terms/:id/edit_synonym' => 'vocabulary_terms#edit_synonym', as: 'vocabulary_terms_edit_synonym'
  get '/vocabulary_terms/:id/remove_synonym' => 'vocabulary_terms#remove_synonym', as: 'vocabulary_terms_remove_synonym'


  # Dashboard User Resources/Collections filtering/sorting
  get '/filter_user_items' => 'dashboard#filter_user_items', as: 'filter_user_items'
  get '/remove_filter' => 'dashboard#remove_filter', as: 'remove_filter'

  # Rendering AJAX modals for resources
  get '/resources/:id/load_media_modal' => 'resources#load_media_modal', as: 'load_media_modal'
  get '/resources/:id/load_fullscreen_slideshow' => 'resources#load_fullscreen_slideshow', as: 'load_fullscreen_slideshow'

  # Pagination for slideshow results
  get 'resources/:id/load_slides' => 'resources#load_slides', as: 'load_slides'

  # Pagination for thumbnail results
  get '/resources/:id/load_thumbnails/:start&:caption' => 'resources#load_thumbnails', as: 'load_thumbnails'

  # PDFJS viewer
  mount PdfjsViewer::Rails::Engine => "/pdfjs", as: 'pdfjs'

  # IIIF
  mount Riiif::Engine => '/image-service', as: 'riiif'

  # Report Mailer
  post '/resources/:id/send_report' => 'resources#send_report'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resources route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resources route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resources route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resources :seller
  #   end

  # Example resources route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resources route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resources route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
