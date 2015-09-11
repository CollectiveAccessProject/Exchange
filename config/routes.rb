Rails.application.routes.draw do
  devise_for :users
  root 'welcome#index'

  resources :resources, :groups

  # media files only exist in resource context, so we basically only need create, update and delete
  # @todo: we might not even need update?!
  resources :media_files, except: [:index, :show, :new, :edit]

  # same goes for media plugin implementations. they can't exist without media_file and resource
  # @todo: we might not even need update?!
  resources :local_files, except: [:index, :show, :new, :edit, :update, :destroy]
  resources :youtube_links, except: [:index, :show, :new, :edit, :update, :destroy]

  # test for adding comments and tags asynchronously
  match '/resources/add_new_comment' => 'resources#add_new_comment', :as => 'add_new_comment_to_resources', :via => [:post]
  match '/resources/add_new_tag' => 'resources#add_new_tag', :as => 'add_new_tag_to_resources', :via => [:post]

  get '/quick_search/query' => 'quick_search#query'


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
