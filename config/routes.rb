# frozen_string_literal: true

Rails.application.routes.draw do
  root 'external#landing'

  namespace :async do
    namespace :forum do
      post :login
      post :new_topic
    end
    namespace :parent do
      post :login
      post :reply
    end
  end

  get 'account(/:auth_token)/profile' => 'account#profile'

  namespace :admin do
    get :dashboard
    get :roles
    get :stats
    get :sync
    get :downloads_by_month
    get :agreement_reports
    resources :replies, only: :index
    root action: :dashboard
  end

  namespace :api do
    namespace :v1 do
      namespace :account do
        get :profile
      end
      resources :datasets, only: [:index, :show] do
        member do
          get :files
        end
      end
      namespace :dictionary do
        post :upload_dataset_csv
        post :upload_file
        post :refresh
        post :update_default_version
      end
      resources :variables, only: [:create, :show, :index] do
        collection do
          post :create_or_update
        end
      end
      # resources :domains
    end
  end

  scope module: :blog do
    get :blog
    get 'blog/category/:category', action: 'blog', as: :blog_category
    get 'blog/author/:author', action: 'blog', as: :blog_author
    get 'blog/:slug', action: 'show'
    get 'blog/:year/:month/:slug', action: 'show', as: :blog_post
    get :blog_archive
  end

  resources :broadcasts, path: 'editor/blog'

  scope module: :agreements do
    namespace :representative do
      get ':representative_token/signature-requested', action: 'signature_requested', as: :signature_requested
      get ':representative_token/submit-signature', action: 'signature_requested'
      patch ':representative_token/submit-signature', action: 'submit_signature', as: :submit_signature
      get 'signature-submitted', action: 'signature_submitted', as: :signature_submitted
    end
  end

  resources :agreements do
    collection do
      get :new_step
      post :create_step
      get :submissions
      get :export
    end
    member do
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

    resources :agreement_events, path: 'events' do
      collection do
        post :preview
      end
    end
  end

  resources :categories

  resources :challenges do
    member do
      get 'images/*path', action: 'images', as: :images, format: false
      get 'signal/:signal', action: 'signal', as: :signal
      post 'signal/:signal', action: 'update_signal', as: :update_signal
      get :review
      get :submitted
    end
  end

  resources :community_tools, path: 'community-tools' do
    resources :community_tool_reviews, path: 'reviews'
  end

  scope module: :editor do
    resources :datasets, only: [:edit, :update] do
      member do
        get :agreements
        get :audits
        get :collaborators
        post :create_access
        post :remove_access
        post :pull_changes
        post :set_public_file
        post 'reset_index(/*path)', action: 'reset_index', as: :reset_index, format: false
        get 'reset_index(/*path)',
            to: redirect { |path_params, _req| "datasets/#{path_params[:id]}/files/#{path_params[:path]}" },
            format: false
        get :sync
      end
    end
  end

  scope module: :admin do
    resources :datasets, only: [:new, :create, :destroy]
  end

  resources :datasets, only: [:show, :index] do
    member do
      get :logo
      get :request_access
      patch :set_access
      get '(/a/:auth_token)/json_manifest(/*path)', action: 'json_manifest', as: :json_manifest, format: false
      get '(/a/:auth_token)/manifest(/*path)', action: 'manifest', as: :manifest, format: false
      get 'files((/a/:auth_token)(/m/:medium)/*path)', action: 'files', as: :files, format: false
      get 'access(/*path)', action: 'access', as: :access, format: false
      get 'search', action: 'search', as: :search
      get 'images/*path', action: 'images', as: :images, format: false
      get 'pages(/*path)', action: 'pages', as: :pages, format: false
      get '/a/:auth_token/editor', action: 'editor', as: :editor
      post :folder_progress
    end

    resources :variables do
      member do
        get :form
        get :graphs
        get :history
        get :known_issues, path: 'known-issues'
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
    # TODO: ENABLE THESE
    # get :settings
    # get :tools
    get :token
  end

  scope module: :external do
    get :about
    get :aug, path: 'about/academic-user-group'
    get :contact
    get :contributors, path: 'about/contributors'
    get :datasharing, path: 'about/data-sharing-language'
    get :demo
    get :landing
    get :sitemap
    get :version

    post :preview
  end

  resources :notifications do
    collection do
      patch :mark_all_as_read
    end
  end

  scope module: 'request' do
    get 'contribute/tool', to: redirect('contribute/tool/start')
    get 'contribute/tool/start', action: 'contribute_tool_start', as: :contribute_tool_start
    post 'contribute/tool/start', action: 'contribute_tool_set_location', as: :contribute_tool_set_location
    post 'contribute/tool', action: 'contribute_tool_register_user', as: :contribute_tool_register_user
    patch 'contribute/tool', action: 'contribute_tool_sign_in_user', as: :contribute_tool_sign_in_user
    get 'contribute/tool/description/:id', action: 'contribute_tool_description', as: :contribute_tool_description
    post 'contribute/tool/description/:id', action: 'contribute_tool_set_description', as: :contribute_tool_set_description
    # post 'contribute/tool/submit', action: 'contribute_tool_submit', as: :contribute_tool_submit

    get 'tool/request', action: 'tool_request', as: :tool_request

    get 'dataset/hosting', to: redirect('dataset/hosting/start')
    get 'dataset/hosting/start', action: 'dataset_hosting_start', as: :dataset_hosting_start
    post 'dataset/hosting/start', action: 'dataset_hosting_set_description', as: :dataset_hosting_set_description
    post 'dataset/hosting', action: 'dataset_hosting_register_user', as: :dataset_hosting_register_user
    patch 'dataset/hosting', action: 'dataset_hosting_sign_in_user', as: :dataset_hosting_sign_in_user
    get 'dataset/hosting/submitted', action: 'dataset_hosting_submitted', as: :dataset_hosting_submitted

    # get 'dataset/hosting', action: 'dataset_hosting', as: :dataset_hosting
    # post 'dataset/hosting', action: 'create_hosting_request', as: :create_hosting_request
    get 'submissions/start', action: 'submissions_start', as: :submissions_start
    post 'submissions/start', action: 'submissions_launch', as: :submissions_launch
    post 'submissions/register', action: 'submissions_register_user', as: :submissions_register_user
    patch 'submissions/sign_in', action: 'submissions_sign_in_user', as: :submissions_sign_in_user
  end

  scope module: :search do
    get :search, action: 'index', as: :search
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
      post :pull_changes
    end
  end

  get 'community/tools/:id' => 'tools#community_show', as: :community_show_tool

  resources :topics, path: 'forum' do
    member do
      post :admin
      post :subscription
      get '/edit', action: :edit, as: :edit
      get '/:page', action: :show, as: :page
    end
    collection do
      get :markup
    end
  end

  resources :replies do
    collection do
      post :preview
    end
    member do
      post :vote
    end
  end

  get 'sitemap.xml.gz' => 'external#sitemap_xml'

  devise_for :users, controllers: { sessions: 'sessions' }, path_names: { sign_up: 'join', sign_in: 'login' }, path: ''

  resources :users

  get '/dua' => 'internal#submissions'
  get '/daua' => 'internal#submissions'

  get '/settings' => 'users#settings', as: :settings
  patch '/settings' => 'users#update_settings', as: :update_settings

  get '/daua/irb-assistance' => 'agreements#irb_assistance', as: :irb_assistance

  # In case 'failed submission steps are reloaded using get request'
  get '/agreements/:id/final_submission' => 'agreements#proof'
  get '/agreements/:id/update_step' => 'agreements#step'
end
