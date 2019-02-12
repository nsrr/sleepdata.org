# frozen_string_literal: true

# Main web application controller for NSRR website. Keeps track of user's
# location for friendly forwarding.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: :devise_login?
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :store_location
  before_action :set_cache_buster

  def store_location
    if !request.post? && !request.xhr? && params[:format] != "atom"
      if internal_action?(params[:controller], params[:action])
        store_internal_location_in_session
      end
      if external_action?(params[:controller], params[:action])
        store_external_location_in_session
      end
    end
  end

  def after_sign_in_path_for(resource)
    return accept_invite_path if session[:invite_token].present?
    session[:previous_internal_url] || session[:previous_external_url] || root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    session[:previous_external_url] || root_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [
        :username, :email, :password, :password_confirmation, :emails_enabled
      ]
    )
  end

  protected

  def internal_controllers
    {
      admin: [],
      agreement_events: [],
      agreements: [:step, :new_step, :proof],
      broadcasts: [],
      categories: [],
      data_requests: [:index, :show, :page, :attest, :submitted],
      datasets: [:index, :show, :new, :edit],
      dataset_reviews: [:new, :edit, :create, :update, :destroy],
      exports: [:show, :index],
      images: [:index, :show, :new, :edit],
      internal: [],
      legal_documents: [],
      notifications: [],
      organizations: [:new, :edit],
      organization_users: [:new, :show, :edit],
      request: [:contribute_tool_description],
      reviews: [],
      settings: [],
      tags: [],
      tool_reviews: [:new, :edit, :create, :update, :destroy],
      tools: [:index, :show, :new, :edit],
      topics: [:new, :edit],
      users: []
    }
  end

  def internal_action?(controller, action)
    internal_controllers[controller.to_sym] && (
      internal_controllers[controller.to_sym].empty? ||
      internal_controllers[controller.to_sym].include?(action.to_sym)
    )
  end

  def external_controllers
    {
      blog: [],
      datasets: [:index, :show],
      dataset_reviews: [:index, :show],
      external: [],
      organizations: [:index, :show],
      organization_users: [:index],
      replies: [:show],
      search: [],
      showcase: [],
      tool_reviews: [:index, :show],
      tools: [:index, :show],
      topics: [:index, :show],
      variables: []
    }
  end

  def external_action?(controller, action)
    external_controllers[controller.to_sym] && (
      external_controllers[controller.to_sym].empty? ||
      external_controllers[controller.to_sym].include?(action.to_sym)
    )
  end

  def devise_login?
    params[:controller] == "sessions" && params[:action] == "create"
  end

  def store_internal_location_in_session
    session[:previous_internal_url] = request.fullpath
  end

  def store_external_location_in_session
    session[:previous_external_url] = request.fullpath
    session[:previous_internal_url] = nil
  end

  def check_community_manager
    return if current_user&.community_manager?
    redirect_to root_path
  end

  def check_admin
    return if current_user&.admin?
    redirect_to root_path
  end

  def parse_date(date_string, default_date = "")
    if date_string.to_s.split("/").last.size == 2
      Date.strptime(date_string, "%m/%d/%y")
    else
      Date.strptime(date_string, "%m/%d/%Y")
    end
  rescue
    default_date
  end

  def empty_response_or_root_path(path = root_path)
    respond_to do |format|
      format.html { redirect_to path }
      format.js { head :ok }
      format.json { head :no_content }
      format.text { head :ok }
    end
  end

  def authenticate_user_from_token!
    user_id               = params[:auth_token].to_s.split("-").first.to_i
    auth_token            = params[:auth_token].to_s.gsub(/^#{user_id}-/, "")
    user                  = user_id && User.find_by(id: user_id)
    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    return unless user && Devise.secure_compare(user.authentication_token, auth_token)
    sign_in user, store: false
  end

  def find_viewable_dataset_or_redirect(id = :dataset_id)
    viewable_datasets = if current_user
                          current_user.all_viewable_datasets
                        else
                          Dataset.released
                        end
    @dataset = viewable_datasets.find_by(slug: params[id])
    redirect_without_dataset
  end

  def find_editable_dataset_or_redirect(id = :dataset_id)
    @dataset = current_user.all_datasets.find_by(slug: params[id]) if current_user
    redirect_without_dataset
  end

  def redirect_without_dataset
    empty_response_or_root_path(datasets_path) unless @dataset
  end

  def find_organization_or_redirect(id = :organization_id)
    @organization = Organization.current.find_by_param(params[id])
    empty_response_or_root_path(organizations_path) unless @organization
  end

  def find_editable_organization_or_redirect(id = :organization_id)
    @organization = current_user.editable_organizations.find_by_param(params[id])
    return if @organization
    organization = current_user.viewable_organizations.find_by_param(params[id])
    empty_response_or_root_path(organization || organizations_path)
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def check_key_and_set_default_value(object, key, default_value)
    return unless params[object].key?(key) && params[object][key].blank?
    params[object][key] = default_value
  end

  def parse_date_if_key_present(object, key)
    return unless params[object].key?(key)
    params[object][key] = parse_date(params[object][key]) if params[object].key?(key)
  end

  # Expects an "Uploader" type class, ex: uploader = @dataset.logo
  def send_file_if_present(uploader, *args)
    if uploader.present?
      send_file uploader.path, *args
    else
      head :ok
    end
  end
end
