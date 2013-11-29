WwwSleepdataOrg::Application.routes.draw do

  # resources :dataset_users

  resources :datasets do
    member do
      get :logo
      get :variable_chart
      get :audits
      get :request_access
      get :requests
      patch :set_access
      get "(/a/:auth_token)/manifest", action: 'manifest', as: :manifest
      get "files((/a/:auth_token)(/m/:medium)/*path)", action: 'files', as: :files, format: false
      get "pages(/*path)", action: 'pages', as: :pages, format: false
      get "edit_page/*path", action: 'edit_page', as: :edit_page, format: false
      patch "update_page/*path", action: 'update_page', as: :update_page, format: false
      get "search", action: 'search', as: :search
    end
  end

  # match "/uploads/:id/:basename.:extension", :controller => "redocuments", :action => "download", :conditions => { :method => :get }

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'register', sign_in: 'login' }

  resources :users

  get 'welcome/index'
  get '/about' => 'welcome#about', as: :about
  get '/contact' => 'welcome#contact', as: :contact
  get '/whatsmyip' => 'welcome#whatsmyip', as: :whatsmyip
  get '/collection' => 'welcome#collection', as: :collection

  get '/tools' => 'welcome#wget', as: :tools
  get '/tools/wget' => 'welcome#wget', as: :wget
  get '/tools/wget/windows' => 'welcome#wget_windows', as: :wget_windows
  get '/tools/wget/src' => 'welcome#wget_src', as: :wget_src

  root to: 'welcome#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
