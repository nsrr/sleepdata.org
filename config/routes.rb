Rails.application.routes.draw do

  resources :topics, path: "forum" do
    member do
      post :admin
      post :subscription
    end
    resources :comments do
      collection do
        post :preview
      end
    end
  end


  resources :agreements do
    member do
      get :download
      get :review
    end
  end

  resources :datasets do
    member do
      get :sync
      get :logo
      get :audits
      get :request_access
      get :requests
      post :create_access
      patch :set_access
      get "(/a/:auth_token)/json_manifest(/*path)", action: 'json_manifest', as: :json_manifest, format: false
      get "(/a/:auth_token)/manifest(/*path)", action: 'manifest', as: :manifest, format: false
      get "files((/a/:auth_token)(/m/:medium)/*path)", action: 'files', as: :files, format: false
      get "search", action: 'search', as: :search

      get "images/*path", action: 'images', as: :images, format: false
      get "pages(/*path)", action: 'pages', as: :pages, format: false
      get "edit_page/*path", action: 'edit_page', as: :edit_page, format: false
      get "new_page(/*path)", action: 'new_page', as: :new_page, format: false
      post "create_page(/*path)", action: 'create_page', as: :create_page, format: false
      patch "update_page/*path", action: 'update_page', as: :update_page, format: false
      post :pull_changes

      post :set_public_file
    end

    resources :variables do
      member do
        get :image
      end
    end
  end

  resources :tools do
    member do
      get :sync
      get :logo

      get :requests
      get :request_access
      post :create_access
      patch :set_access

      get "images/*path", action: 'images', as: :images, format: false
      get "pages(/*path)", action: 'pages', as: :pages, format: false
      get "edit_page/*path", action: 'edit_page', as: :edit_page, format: false
      get "new_page(/*path)", action: 'new_page', as: :new_page, format: false
      post "create_page(/*path)", action: 'create_page', as: :create_page, format: false
      patch "update_page/*path", action: 'update_page', as: :update_page, format: false
      post :pull_changes
    end
  end

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'register', sign_in: 'login' }

  resources :users

  get 'welcome/index'
  get '/about' => 'welcome#about', as: :about
  get '/about/aug' => 'welcome#aug', as: :aug
  get '/contact' => 'welcome#contact', as: :contact
  get '/sync' => 'welcome#sync', as: :sync
  get '/stats' => 'welcome#stats', as: :stats
  get '/location' => 'welcome#location', as: :location
  get '/collection' => 'welcome#collection', as: :collection
  get '/collection_modal' => 'welcome#collection_modal', as: :collection_modal
  get '/token' => 'welcome#token', as: :token

  get '/tools/wget/windows' => 'welcome#wget_windows', as: :wget_windows
  get '/tools/wget/src' => 'welcome#wget_src', as: :wget_src

  get '/dua' => 'agreements#dua'
  get '/daua' => 'agreements#daua', as: :daua
  post '/daua' => 'agreements#submit', as: :upload_daua
  patch '/daua' => 'agreements#resubmit', as: :reupload_daua
  get '/triage' => 'agreements#triage', as: :triage
  get '/triage_student' => 'agreements#triage_student', as: :triage_student
  get '/triage_researcher' => 'agreements#triage_researcher', as: :triage_researcher
  get '/triage_company' => 'agreements#triage_company', as: :triage_company
  get '/daua/step/*step' => 'agreements#step', as: :daua_step
  get '/daua/irb_assistance_template' => 'agreements#irb_assistance_template', as: :irb_assistance_template
  get '/settings' => 'users#settings', as: :settings
  patch '/settings' => 'users#update_settings', as: :update_settings

  root to: 'welcome#index'

end
