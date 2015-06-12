Rails.application.routes.draw do

  get "account(/:auth_token)/profile" => "account#profile"

  resources :tags

  resources :topics, path: "forum" do
    member do
      post :admin
      post :subscription
    end
    collection do
      get :markup
    end
    resources :comments do
      collection do
        post :preview
      end
    end
  end

  resources :agreements do
    collection do
      get :new_step
      post :create_step
      get :submissions
      get "signature-submitted", action: 'signature_submitted', as: :signature_submitted
    end
    member do
      get ":duly_authorized_representative_token/signature-requested", action: 'signature_requested', as: :signature_requested
      get ":duly_authorized_representative_token/duly_authorized_representative_submit_signature", action: 'signature_requested'
      patch ":duly_authorized_representative_token/duly_authorized_representative_submit_signature", action: 'duly_authorized_representative_submit_signature', as: :duly_authorized_representative_submit_signature
      get :download
      get :review
      get :step
      patch :update_step
      get :proof
      patch :final_submission
      get :complete
      get :renew
      get :download_irb
      get :print
      delete :destroy_submission
    end
  end

  resources :challenges do
    member do
      get "images/*path", action: 'images', as: :images, format: false
      get "signal/:signal", action: 'signal', as: :signal
      post "signal/:signal", action: 'update_signal', as: :update_signal
      get :review
    end
  end

  scope module: 'challenges' do
    get "challenges/flow-limitation/submitted", action: 'submitted', as: :flow_limitation_challenge_submitted
  end


  resources :datasets do
    member do
      get :sync
      get :logo
      get :audits
      get :request_access
      get :requests
      post :create_access
      post :remove_access
      patch :set_access
      get "(/a/:auth_token)/json_manifest(/*path)", action: 'json_manifest', as: :json_manifest, format: false
      get "(/a/:auth_token)/manifest(/*path)", action: 'manifest', as: :manifest, format: false
      get "files((/a/:auth_token)(/m/:medium)/*path)", action: 'files', as: :files, format: false
      get "access(/*path)", action: 'access', as: :access, format: false
      post "reset_index(/*path)", action: 'reset_index', as: :reset_index, format: false
      get "reset_index(/*path)", to: redirect{|path_params, req| "datasets/#{path_params[:id]}/files/#{path_params[:path]}" }, format: false
      get "search", action: 'search', as: :search

      get "images/*path", action: 'images', as: :images, format: false
      get "pages(/*path)", action: 'pages', as: :pages, format: false
      get "edit_page/*path", action: 'edit_page', as: :edit_page, format: false
      get "new_page(/*path)", action: 'new_page', as: :new_page, format: false
      post "create_page(/*path)", action: 'create_page', as: :create_page, format: false
      patch "update_page/*path", action: 'update_page', as: :update_page, format: false
      post :pull_changes

      post :set_public_file
      post :upload_graph
      post :upload_dataset_csv
      get "/a/:auth_token/refresh_dictionary", action: 'refresh_dictionary', as: :refresh_dictionary
      get "/a/:auth_token/editor", action: 'editor', as: :editor
    end

    resources :variables do
      member do
        get :image
      end
    end
  end

  get "/a/:auth_token/datasets" => 'datasets#index'
  get "/a/:auth_token/datasets/:id" => 'datasets#show'

  resources :reviews do
    member do
      post :create_comment
      post :preview
      post :show_comment
      get :edit_comment
      post :update_comment
      post :destroy_comment
      post :vote
      post :update_tags
    end
  end

  scope module: 'showcase' do
    get :showcase, action: 'index', as: :showcase
    get "showcase(/:slug)", action: 'show', as: :showcase_show
  end

  scope module: 'static' do
    get :demo
    get :parallax
    get :parallax2
    get :map
    get :version
    get :sizes
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

  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions', passwords: 'passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'join', sign_in: 'login' }, path: ""

  resources :users

  get 'welcome/index'
  get '/about' => 'welcome#about', as: :about
  get '/about/aug' => 'welcome#aug', as: :aug
  get '/contact' => 'welcome#contact', as: :contact
  get '/sync' => 'welcome#sync', as: :sync
  get '/stats' => 'welcome#stats', as: :stats
  get '/downloads_by_month' => 'welcome#downloads_by_month', as: :downloads_by_month
  get '/agreement_reports' => 'welcome#agreement_reports', as: :agreement_reports
  get '/location' => 'welcome#location', as: :location
  get '/collection' => 'welcome#collection', as: :collection
  get '/collection_modal' => 'welcome#collection_modal', as: :collection_modal
  get '/token' => 'welcome#token', as: :token

  get '/dua' => 'agreements#submissions'
  get '/daua' => 'agreements#submissions'

  get '/settings' => 'users#settings', as: :settings
  patch '/settings' => 'users#update_settings', as: :update_settings


  get '/admin' => 'admin#dashboard'
  get '/admin/dashboard' => 'admin#dashboard', as: :admin_dashboard

  get '/daua/irb_assistance_template' => 'agreements#irb_assistance_template', as: :irb_assistance_template

  get '/submissions' => 'agreements#submissions', as: :submissions
  get '/submissions/welcome' => 'agreements#welcome', as: :submissions_welcome
  get '/submissions/start' => 'agreements#new_step', as: :submissions_start

  # In case "failed submission steps are reloaded using get request"
  get '/agreements/:id/final_submission' => 'agreements#proof'
  get '/agreements/:id/update_step' => 'agreements#step'


  root to: 'welcome#index'

end
