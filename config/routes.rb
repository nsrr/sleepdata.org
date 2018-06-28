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
    get "blog/category/:category", action: "blog", as: :blog_category
    get "blog/author/:author", action: "blog", as: :blog_author
    get "blog/:slug", action: "show"
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

  resources :agreements do
    collection do
      post :export
    end

    resources :agreement_events, path: "events" do
      collection do
        post :preview
      end
    end
  end

  resources :categories

  resources :community_tools, path: "community-tools" do
    resources :community_tool_reviews, path: "reviews"
  end

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

  scope module: :editor do
    resources :datasets, only: [:edit, :update] do
      member do
        get :agreements
        get :audits
        get :collaborators
        get :page_views, path: "page-views"
        post :create_access
        post :remove_access
        post :pull_changes
        post :set_public_file
        post "reset_index(/*path)", action: "reset_index", as: :reset_index, format: false
        get "reset_index(/*path)",
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
    resources :dataset_reviews, path: "reviews"

    member do
      get :logo
      get :request_access
      patch :set_access
      get "(/a/:auth_token)/json_manifest(/*path)", action: "json_manifest", as: :json_manifest, format: false
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

  resources :exports do
    member do
      post :progress
      get :download
    end
  end

  resources :hosting_requests, path: "hosting-requests"

  resources :images do
    collection do
      post :upload, action: :create_multiple
    end
  end

  get "/image/:id" => "images#download", as: "download_image"

  namespace :organizations, path: "orgs/:id" do
    namespace :reports do
      get :data_requests, path: "data-requests"
      get :data_request_stats, path: "data-requests/stats"
      get :this_month, path: "this-month"
    end
  end

  resources :organizations, path: "orgs" do
    resources :legal_documents, path: "legal-documents" do
      resources :legal_document_pages, path: "pages"
      # resources :legal_document_pages, path: "pages", as: :page, only: [:show, :edit, :update, :destroy]
      # resources :legal_document_pages, path: "pages", as: :pages, only: [:index, :create]
      resources :legal_document_variables, path: "variables"
    end

    member do
      get :datasets
      get :people
      get :invite_member, path: "people/invite"
      post :add_member, path: "people/invite"
    end

    resources :legal_document_datasets, path: "legal-document-datasets"
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
      post :update_agreement_variable
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
      get :tools
    end
  end

  resources :notifications do
    collection do
      patch :mark_all_as_read
    end
  end

  scope module: "request" do
    get "contribute/tool", to: redirect("contribute/tool/start")
    get "contribute/tool/start", action: "contribute_tool_start", as: :contribute_tool_start
    post "contribute/tool/start", action: "contribute_tool_set_location", as: :contribute_tool_set_location
    get "contribute/tool/confirm-email", action: "contribute_tool_confirm_email", as: :contribute_tool_confirm_email
    post "contribute/tool", action: "contribute_tool_register_user", as: :contribute_tool_register_user
    patch "contribute/tool", action: "contribute_tool_sign_in_user", as: :contribute_tool_sign_in_user
    get "contribute/tool/description/:id", action: "contribute_tool_description", as: :contribute_tool_description
    post "contribute/tool/description/:id", action: "contribute_tool_set_description", as: :contribute_tool_set_description
    # post "contribute/tool/submit", action: "contribute_tool_submit", as: :contribute_tool_submit

    get "tool/request", action: "tool_request", as: :tool_request

    get "dataset/hosting", to: redirect("dataset/hosting/start")
    get "dataset/hosting/start", action: "dataset_hosting_start", as: :dataset_hosting_start
    post "dataset/hosting/start", action: "dataset_hosting_set_description", as: :dataset_hosting_set_description
    post "dataset/hosting", action: "dataset_hosting_register_user", as: :dataset_hosting_register_user
    patch "dataset/hosting", action: "dataset_hosting_sign_in_user", as: :dataset_hosting_sign_in_user
    get "dataset/hosting/submitted", action: "dataset_hosting_submitted", as: :dataset_hosting_submitted
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

  resources :tools, only: [:index, :show]

  # TODO: Remove on or after October 1, 2018.
  get "community/tools/:id", as: :community_show_tool, to: redirect("tools/%{id}")
  get "community/tools", to: redirect("tools")
  # END TODO

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

  get "/submissions", to: redirect("data/requests")
  get "/fair", to: redirect("about/fair-data-principles")

  # In case "failed submission steps are reloaded using get request"
  get "/agreements/:id/final_submission" => "agreements#proof"
  get "/agreements/:id/update_step" => "agreements#step"
end
