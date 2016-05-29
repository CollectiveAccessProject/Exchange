Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => 'users/omniauth_callbacks' }

  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session_path
  end

  root 'welcome#index'

  resources :resources, :groups

  # add new collection - just a resource with the resource_type preset
  get '/collections/new' => 'resources#new', type: 'collection', as: "new_collection"
  get '/collections/new/resource/:child_id' => 'resources#new', type: 'collection', as: "new_collection_with_id"
  get '/resources/setParent/:id' => 'resources#update', as: "set_resource_parent_with_id"

  # add new resource to collection
  get '/resources/new/collection/:parent_id' => "resources#new", type: 'resource', as: "new_resource_for_collection_with_id"

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

  # test for adding comments and tags asynchronously
  match '/resources/add_new_comment' => 'resources#add_new_comment', :as => 'add_new_comment_to_resources', :via => [:post]
  match '/resources/add_new_tag' => 'resources#add_new_tag', :as => 'add_new_tag_to_resources', :via => [:post]

  # save preferences via ajax, get JSON in return
  post '/resources/:id/save_preferences' => 'resources#save_preferences',  defaults: { format: 'json' }

  get '/quick_search/query' => 'quick_search#query'
  get '/dashboard' => 'dashboard#index'

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
