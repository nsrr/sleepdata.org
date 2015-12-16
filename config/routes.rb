Rails.application.routes.draw do
  resources :community_tools, path: 'community-tools'
  get 'account(/:auth_token)/profile' => 'account#profile'

  scope module: :blog do
    get :blog
    get 'blog/:id', action: 'show', as: :blog_post
    get 'blog/:id/image', action: 'image', as: :blog_post_image
    get :blog_archive
  end

  resources :broadcasts

  resources :agreements do
    collection do
      get :new_step
      post :create_step
      get :submissions
      get 'signature-submitted', action: 'signature_submitted', as: :signature_submitted
      get :export
    end
    member do
      get ':duly_authorized_representative_token/signature-requested', action: 'signature_requested', as: :signature_requested
      get ':duly_authorized_representative_token/duly_authorized_representative_submit_signature', action: 'signature_requested'
      patch ':duly_authorized_representative_token/duly_authorized_representative_submit_signature', action: 'duly_authorized_representative_submit_signature', as: :duly_authorized_representative_submit_signature
      get :download
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
      get 'images/*path', action: 'images', as: :images, format: false
      get 'signal/:signal', action: 'signal', as: :signal
      post 'signal/:signal', action: 'update_signal', as: :update_signal
      get :review
      get :submitted
    end
  end

  scope module: 'challenges' do
    get 'challenges/flow-limitation/submitted', action: 'submitted', as: :flow_limitation_challenge_submitted
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
      get '(/a/:auth_token)/json_manifest(/*path)', action: 'json_manifest', as: :json_manifest, format: false
      get '(/a/:auth_token)/manifest(/*path)', action: 'manifest', as: :manifest, format: false
      get 'files((/a/:auth_token)(/m/:medium)/*path)', action: 'files', as: :files, format: false
      get 'access(/*path)', action: 'access', as: :access, format: false
      post 'reset_index(/*path)', action: 'reset_index', as: :reset_index, format: false
      get 'reset_index(/*path)', to: redirect{|path_params, req| 'datasets/#{path_params[:id]}/files/#{path_params[:path]}' }, format: false
      get 'search', action: 'search', as: :search

      get 'images/*path', action: 'images', as: :images, format: false
      get 'pages(/*path)', action: 'pages', as: :pages, format: false
      get 'edit_page/*path', action: 'edit_page', as: :edit_page, format: false
      get 'new_page(/*path)', action: 'new_page', as: :new_page, format: false
      post 'create_page(/*path)', action: 'create_page', as: :create_page, format: false
      patch 'update_page/*path', action: 'update_page', as: :update_page, format: false
      post :pull_changes

      post :set_public_file
      post :upload_graph
      post :upload_dataset_csv
      get '/a/:auth_token/refresh_dictionary', action: 'refresh_dictionary', as: :refresh_dictionary
      get '/a/:auth_token/editor', action: 'editor', as: :editor
    end

    resources :variables do
      member do
        get :form
        get :graphs
        get :history
        get :image
        get :known_issues
        get :related
      end
    end
  end

  get '/a/:auth_token/datasets' => 'datasets#index'
  get '/a/:auth_token/datasets/:id' => 'datasets#show'

  resources :hosting_requests, path: 'hosting-requests'

  resources :images do
    collection do
      post :upload, action: :create_multiple
    end
  end

  get '/image/:id' => 'images#download', as: 'download_image'

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
      get :transactions
    end
  end

  scope module: 'showcase' do
    get :showcase, action: 'index', as: :showcase
    get 'showcase(/:slug)', action: 'show', as: :showcase_show
  end

  scope module: :internal do
    get :dashboard
    get :profile
    get :submissions
    # TODO ENABLE THESE
    # get :settings
    # get :tools
  end

  scope module: :external do
    # TODO ENABLE THESE
    # get :about
    # get :contact
    get :landing
    get :sitemap
    post :preview
  end

  scope module: 'request' do
    get 'contribute/tool', to: redirect('contribute/tool/start')
    get 'contribute/tool/start', action: 'contribute_tool_start', as: :contribute_tool_start
    post 'contribute/tool/start', action: 'contribute_tool_set_location', as: :contribute_tool_set_location
    get 'contribute/tool/about-me', action: 'contribute_tool_about_me', as: :contribute_tool_about_me
    post 'contribute/tool/about-me', action: 'contribute_tool_register_user', as: :contribute_tool_register_user
    patch 'contribute/tool/about-me', action: 'contribute_tool_sign_in_user', as: :contribute_tool_sign_in_user
    get 'contribute/tool/submitted', action: 'contribute_tool_submitted', as: :contribute_tool_submitted

    get 'contribute/tool/location', action: 'contribute_tool_location', as: :contribute_tool_location

    get 'contribute/tool/description/:id', action: 'contribute_tool_description', as: :contribute_tool_description
    post 'contribute/tool/description/:id', action: 'contribute_tool_set_description', as: :contribute_tool_set_description
    get 'contribute/tool/preview', action: 'contribute_tool_preview', as: :contribute_tool_preview
    post 'contribute/tool/submit', action: 'contribute_tool_submit', as: :contribute_tool_submit

    get 'tool/contribute', action: 'tool_contribute', as: :tool_contribute
    post 'tool/contribute', action: 'create_tool_contribute', as: :create_tool_contribute
    get 'tool/contribute/submitted', action: 'tool_contribute_submitted', as: :tool_contribute_submitted
    get 'tool/request', action: 'tool_request', as: :tool_request
    get 'dataset/hosting', action: 'dataset_hosting', as: :dataset_hosting
    post 'dataset/hosting', action: 'create_hosting_request', as: :create_hosting_request
    get 'dataset/hosting/submitted', action: 'dataset_hosting_submitted', as: :dataset_hosting_submitted
  end

  scope module: 'static' do
    get :demo
    get :map
    get :version
  end

  resources :tags

  resources :tools do
    member do
      get :sync
      get :logo

      get :requests
      get :request_access
      post :create_access
      patch :set_access

      get 'images/*path', action: 'images', as: :images, format: false
      get 'pages(/*path)', action: 'pages', as: :pages, format: false
      get 'edit_page/*path', action: 'edit_page', as: :edit_page, format: false
      get 'new_page(/*path)', action: 'new_page', as: :new_page, format: false
      post 'create_page(/*path)', action: 'create_page', as: :create_page, format: false
      patch 'update_page/*path', action: 'update_page', as: :update_page, format: false
      post :pull_changes
    end
  end

  get 'community/tools/:id' => 'tools#community_show', as: :community_show_tool


  resources :topics, path: 'forum' do
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

  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions', passwords: 'passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'join', sign_in: 'login' }, path: ''

  resources :users

  # TODO: Move these to modules
  get 'welcome/index'
  get '/about' => 'welcome#about', as: :about
  get '/about/aug' => 'welcome#aug', as: :aug
  get '/contact' => 'welcome#contact', as: :contact
  get '/sync' => 'welcome#sync', as: :sync
  get '/stats' => 'welcome#stats', as: :stats
  get '/downloads_by_month' => 'welcome#downloads_by_month', as: :downloads_by_month
  get '/agreement_reports' => 'welcome#agreement_reports', as: :agreement_reports
  get '/location' => 'welcome#location', as: :location
  get '/token' => 'welcome#token', as: :token

  get '/dua' => 'internal#submissions'
  get '/daua' => 'internal#submissions'

  get '/settings' => 'users#settings', as: :settings
  patch '/settings' => 'users#update_settings', as: :update_settings

  get '/admin' => 'admin#dashboard'
  get '/admin/dashboard' => 'admin#dashboard', as: :admin_dashboard
  get '/admin/roles' => 'admin#roles', as: :admin_roles

  get '/daua/irb-assistance' => 'agreements#irb_assistance', as: :irb_assistance

  get '/submissions/welcome' => 'agreements#welcome', as: :submissions_welcome
  get '/submissions/start' => 'agreements#new_step', as: :submissions_start

  # In case 'failed submission steps are reloaded using get request'
  get '/agreements/:id/final_submission' => 'agreements#proof'
  get '/agreements/:id/update_step' => 'agreements#step'

  root to: 'external#landing'
end
