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

  get "account(/:auth_token)/profile" => "account#profile"

  get "admin", to: redirect("dashboard")

  namespace :admin do
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
    get :request_as_individual_or_organization, path: ":dataset_id/request-as/individual-or-organization"
    post :update_individual_or_organization, path: ":dataset_id/request-as/individual-or-organization"
    get :intended_use_noncommercial_or_commercial, path: ":dataset_id/intended-use/noncommercial-or-commercial"
    post :update_noncommercial_or_commercial, path: ":dataset_id/intended-use/noncommercial-or-commercial"
    get :page, path: ":data_request_id/page/:page"
    post :update_page, path: ":data_request_id/page/:page"
    get :attest, path: ":data_request_id/attest"
    post :update_attest, path: ":data_request_id/attest"
    get :addendum, path: ":data_request_id/addendum/:addendum"
    get :addons, path: ":data_request_id/addons"
    # get :attachments, path: ":data_request_id/attachments"
    get :proof, path: ":data_request_id/proof"
    get :signature, path: ":data_request_id/signature"
    get :duly_authorized_representative_signature, path: ":data_request_id/duly_authorized_representative_signature"
    post :submit, path: ":data_request_id/proof"
    get :submitted, path: ":data_request_id/submitted"
    get :print, path: ":data_request_id/print"
  end

  resources :data_requests, path: "data/requests", only: :index do
    resources :supporting_documents, path: "supporting-documents", except: [:edit, :update] do
      collection do
        post :upload, action: :create_multiple
      end
    end
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
      get "(/a/:auth_token)/manifest(/*path)", action: "manifest", as: :manifest, format: false
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

  resources :hosting_requests, path: "hosting-requests"

  resources :images do
    collection do
      post :upload, action: :create_multiple
    end
  end

  get "/image/:id" => "images#download", as: "download_image"

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
      get :legal_templates, path: "legal/templates"
      get :legal_template_one, path: "legal/templates/1"
      get :legal_template_two, path: "legal/templates/2"
      get :legal_template_three, path: "legal/templates/3"
      get :legal_template_four, path: "legal/templates/4"
      get :legal_template_five, path: "legal/templates/5"
      get :legal_template_six, path: "legal/templates/6"
      get :legal_template_seven, path: "legal/templates/7"
      get :legal_template_eight, path: "legal/templates/8"
    end

    resources :legal_document_datasets, path: "legal-document-datasets"
  end

  resources :reviews do
    member do
      get :show2
      get :signature
      get :duly_authorized_representative_signature
      post :vote
      post :update_tags
      get :transactions
    end
  end

  scope module: "showcase" do
    get :showcase, action: "index", as: :showcase
    get "showcase(/:slug)", action: "show", as: :showcase_show
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
    get :aug, path: "about/academic-user-group"
    get :contact
    get :contributors, path: "about/contributors"
    get :datasharing, path: "about/data-sharing-language"
    get :demo
    get :landing
    get :landing_custom_header
    get :landing_no_header
    get :share
    get :sitemap
    get :team
    get :version
    get :voting
    get :sitemap_xml, path: "sitemap.xml.gz"

    post :preview
  end

  # TODO: Remove
  scope module: :gears do
    get :assign_commercial_type, path: "gears/noncommercial-or-commercial"
    post :update_commercial_type, path: "gears/noncommercial-or-commercial"
    get :assign_data_user_type, path: "gears/individual-or-organization"
    post :update_data_user_type, path: "gears/individual-or-organization"
    get :no_legal_doc_found, path: "gears/no-legal-doc-found"
    get :agreement_start, path: "agreement/start"
    get :agreement_page, path: "agreement/page/:page"
    post :update_agreement_page, path: "agreement/page/:page"
    get :agreement_attest_signature, path: "agreement/attest/signature"
    post :update_agreement_attest_signature, path: "agreement/attest/signature"
    get :agreement_signature, path: "agreement/signature"
    get :agreement_duly_authorized_representative_signature, path: "agreement/duly_authorized_representative_signature"
    get :agreement_reviewer_signature, path: "agreement/reviewer_signature"
    get :agreement_attest, path: "agreement/attest"
    post :update_agreement_attest, path: "agreement/attest"
    get :agreement_proof, path: "agreement/proof"
    post :agreement_submit, path: "agreement/proof"
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

    get "submissions/start", action: "submissions_start", as: :submissions_start
    post "submissions/start", action: "submissions_launch", as: :submissions_launch
    post "submissions/register", action: "submissions_register_user", as: :submissions_register_user
    patch "submissions/sign_in", action: "submissions_sign_in_user", as: :submissions_sign_in_user
  end

  scope module: :search do
    get :search, action: "index", as: :search
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

      get "images/*path", action: "images", as: :images, format: false
      get "pages(/*path)", action: "pages", as: :pages, format: false
      post :pull_changes
    end
  end

  get "community/tools/:id" => "tools#community_show", as: :community_show_tool

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
               sessions: "sessions", registrations: "registrations"
             },
             path_names: {
               sign_up: "join", sign_in: "login"
             },
             path: ""

  resources :users

  get "/dua" => "internal#submissions"
  get "/daua" => "internal#submissions"

  get "/settings" => "users#settings", as: :settings
  patch "/settings" => "users#update_settings", as: :update_settings
  get "/change_password", to: redirect("settings"), as: :change_password_settings
  patch "/change_password" => "users#change_password", as: :change_password

  get "/daua/irb-assistance" => "agreements#irb_assistance", as: :irb_assistance

  # In case "failed submission steps are reloaded using get request"
  get "/agreements/:id/final_submission" => "agreements#proof"
  get "/agreements/:id/update_step" => "agreements#step"
end
