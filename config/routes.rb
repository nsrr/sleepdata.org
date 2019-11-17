# frozen_string_literal: true

Rails.application.routes.draw do
  root "external#landing"

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

  namespace :account do
    get :profile, path: "(/:auth_token)/profile"
  end

  get "admin" => "admin#dashboard", as: :admin

  namespace :admin do
    get :spam_inbox, path: "spam-inbox"
    get :spam_report, path: "spam-report(/:year)"
    get :profile_review, path: "profile-review"
    post :submit_profile_review, path: "profile-review"
    post :unspamban, path: "unspamban/:id"
    post :destroy_spammer, path: "empty-spam/:id"
    post :empty_spam, path: "empty-spam"
    get :roles
    get :stats
    get :sync
    get :downloads_by_month, path: "downloads-by-month"
    get :downloads_by_quarter, path: "downloads-by-quarter"
    get :agreement_reports, path: "agreement-reports"
    get :searches
    resources :replies, only: :index
    resources :tools
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
    get "blog/category/:category", action: "blog", as: :blog_category
    get "blog/author/:author", action: "blog", as: :blog_author
    get "blog/:slug", action: "show", as: :blog_slug
    get "blog/:slug/cover", action: "cover", as: :blog_cover
    get "blog/:year/:month/:slug", action: "show", as: :blog_post
    get :blog_archive
  end

  resources :broadcasts, path: "editor/blog"

  scope module: :agreements do
    namespace :representative do
      get ":representative_token/signature-requested", action: "signature_requested", as: :signature_requested
      get ":representative_token/submit-signature", action: "signature_requested"
      patch ":representative_token/submit-signature", action: "submit_signature", as: :submit_signature
      get "signature-submitted", action: "signature_submitted", as: :signature_submitted
    end
  end

  resources :agreements, only: [] do
    resources :agreement_events, path: "events" do
      collection do
        post :preview
      end
    end
  end

  resources :categories

  namespace :data_requests, path: "data/requests" do
    get :start, path: ":dataset_id/start"
    post :create, path: ":dataset_id/start"
    get :join, path: ":dataset_id/join", to: redirect("data/requests/%{dataset_id}/start")
    post :join, path: ":dataset_id/join"
    get :login, path: ":dataset_id/login", to: redirect("data/requests/%{dataset_id}/start")
    post :login, path: ":dataset_id/login"
    get :no_legal_documents, path: ":dataset_id/no-legal-documents"
    get :convert, path: ":data_request_id/convert", to: redirect("data/requests/%{data_request_id}/page/1")
    post :convert, path: ":data_request_id/convert"
    get :page, path: ":data_request_id/page/:page"
    post :update_page, path: ":data_request_id/page/:page"
    get :attest, path: ":data_request_id/attest"
    post :update_attest, path: ":data_request_id/attest"
    get :duly_authorized_representative, path: ":data_request_id/duly-authorized-representative"
    post :update_duly_authorized_representative, path: ":data_request_id/duly-authorized-representative"
    get :addendum, path: ":data_request_id/addendum/:addendum"
    get :proof, path: ":data_request_id/proof"
    get :signature, path: ":data_request_id/signature"
    get :duly_authorized_representative_signature, path: ":data_request_id/duly-authorized-representative/signature"
    post :submit, path: ":data_request_id/proof"
  end

  resources :data_requests, path: "data/requests", only: [:index, :show, :destroy] do
    member do
      get :resubmit
      get :resume
      get :submitted
      get :print
      get :datasets
      post :update_datasets, path: "datasets"
    end
    resources :supporting_documents, path: "supporting-documents", except: [:edit, :update] do
      collection do
        post :upload, action: :create_multiple
      end
    end
  end

  get "data", to: redirect("datasets")

  scope module: :principal_reviewer do
    resources :data_requests, path: "data-requests", only: [] do
      member do
        patch :review
      end
    end
  end

  scope module: :editor do
    resources :datasets, only: [:new, :create, :edit, :update, :destroy] do
      member do
        get :data_requests, path: "data-requests"
        get :audits
        get :collaborators
        get :page_views, path: "page-views"
        get :settings
        get :sync
        post :create_access
        post :remove_access
        post :pull_changes
        post :set_public_file
        post "reset_index(/*path)", action: "reset_index", as: :reset_index, format: false
        get "reset_index(/*path)",
            to: redirect { |path_params, _req| "datasets/#{path_params[:id]}/files/#{path_params[:path]}" },
            format: false
      end
    end

    resources :organizations, only: [:edit, :update], path: "orgs" do
      member do
        get :settings
      end
    end
  end

  scope module: :admin do
    resources :organizations, only: [:new, :create, :destroy], path: "orgs"
  end

  scope module: :viewer do
    resources :organizations, only: [], path: "orgs" do
      member do
        get :data_requests, path: "reports/data-requests"
        get :data_downloads, path: "reports/data-downloads"
        get :membership, path: "reports/membership"
        get :data_requests_year_to_date, path: "reports/data-requests/year-to-date"
        get :data_requests_since_inception, path: "reports/data-requests/since-inception"

        get :data_requests_total, path: "reports/data-requests/total"
        get :data_requests_submitted, path: "reports/data-requests/submitted"
        get :data_requests_approved, path: "reports/data-requests/approved"
      end

      resources :exports, only: [:index, :show, :create, :destroy] do
        member do
          post :progress
          get :download
        end
      end
    end
  end

  resources :datasets, only: [:show, :index] do
    resources :dataset_reviews, path: "reviews"

    member do
      get :logo
      get :request_access
      patch :set_access
      get "files((/a/:auth_token)(/m/:medium)/*path)", action: "files", as: :files, format: false
      get "access(/*path)", action: "access", as: :access, format: false
      get "search", action: "search", as: :search
      get "images/*path", action: "images", as: :images, format: false
      get "pages(/*path)", action: "pages", as: :pages, format: false
      get "/a/:auth_token/editor", action: "editor", as: :editor
      post :folder_progress
    end

    resources :variables do
      member do
        get :form
        get :graphs
        get :history
        get :known_issues, path: "known-issues"
        get :related
      end
    end
  end

  get "/a/:auth_token/datasets" => "datasets#index"
  get "/a/:auth_token/datasets/:id" => "datasets#show"

  resources :images do
    collection do
      post :upload, action: :create_multiple
    end
  end

  get "/image/:id" => "images#download", as: "download_image"

  resources :organizations, only: [:show, :index], path: "orgs" do
    resources :legal_document_datasets, path: "legal-document-datasets"

    resources :legal_documents, path: "legal-documents" do
      collection do
        get :coverage
      end

      resources :legal_document_pages, path: "pages"
      # resources :legal_document_pages, path: "pages", as: :page, only: [:show, :edit, :update, :destroy]
      # resources :legal_document_pages, path: "pages", as: :pages, only: [:index, :create]
      resources :legal_document_variables, path: "variables"
    end

    resources :organization_users, path: "members"
  end

  namespace :reviewer do
    resources :agreement_variables, path: ":data_request_id/agreement-variables", only: [:edit, :update]
    resources :supporting_documents, path: ":data_request_id/supporting-documents" do
      collection do
        post :upload, action: :create_multiple
      end
    end
  end

  resources :reviews do
    member do
      get :signature
      get :duly_authorized_representative_signature
      get :reviewer_signature
      post :vote
      post :update_tags
      get :transactions
      get :print
      get :autocomplete
      post :update_agreement_variable
      delete :reset_signature, path: "reset-signature"
    end
  end

  scope module: "showcase" do
    get :showcase, action: "index", as: :showcase
    get "showcase(/:slug)", action: "show", as: :showcase_show
  end

  scope module: :internal do
    get :dashboard
    get :token
  end

  scope module: :external do
    get :about
    get :aug, path: "about/academic-user-group"
    get :contact
    get :contributors, path: "about/contributors"
    get :datasharing, path: "about/data-sharing-language"
    get :demo
    get :fair, path: "about/fair-data-principles"
    get :landing
    get :privacy_policy, path: "privacy-policy"
    get :share
    get :sitemap
    get :team
    get :version
    get :voting
    get :sitemap_xml, path: "sitemap.xml.gz"
    post :preview
  end

  resources :members do
    member do
      get :profile_picture
      get :posts
    end
  end

  resources :notifications do
    collection do
      patch :mark_all_as_read
    end
  end

  scope module: :search do
    get :search, action: "index", as: :search
  end

  get :settings, to: redirect("settings/profile")
  namespace :settings do
    get :profile
    patch :update_profile, path: "profile"
    get :profile_picture, path: "profile/picture", to: redirect("settings/profile")
    patch :update_profile_picture, path: "profile/picture"

    get :account
    patch :update_account, path: "account"
    get :password, to: redirect("settings/account")
    patch :update_password, path: "password"
    delete :destroy, path: "account", as: "delete_account"

    get :email
    patch :update_email, path: "email"

    get :data_requests, path: "data-requests"
    patch :update_data_requests, path: "data-requests"
  end

  resources :tags

  resources :tools, only: :index

  resources :topics, path: "forum" do
    member do
      post :admin
      post :subscription
      get "/edit", action: :edit, as: :edit
      get "/:page", action: :show, as: :page
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

  devise_for :users,
             controllers: {
               confirmations: "confirmations",
               passwords: "passwords",
               registrations: "registrations",
               sessions: "sessions",
               unlocks: "unlocks"
             },
             path_names: {
               sign_up: "join",
               sign_in: "login"
             },
             path: ""

  resources :users

  get "invite/:invite_token" => "organization_users#invite", as: :invite
  get "accept-invite" => "organization_users#accept_invite", as: :accept_invite

  get "submissions", to: redirect("data/requests")
  get "fair", to: redirect("about/fair-data-principles")

  # TODO: Remove "community" redirect after March 31, 2024
  get "community/tools/nsrr-spectraltrainfig", to: redirect("https://github.com/nsrr/SpectralTrainFig")
  get "community(/*path)", to: redirect("")
  # END TODO

  # TODO: Redirect tools show pages, remove redirect after April 30, 2024
  get "tools/*path", to: redirect("tools")
  # END TODO
end
