# frozen_string_literal: true

# Main web application controller for NSRR website. Keeps track of user's
# location for friendly forwarding.
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :store_location
  before_action :set_cache_buster

  def store_location
    if (!request.post? &&
        params[:controller] != 'internal' &&
        params[:action] != 'download' &&
        params[:action] != 'logo' &&
        params[:action] != 'files' &&
        params[:action] != 'variable_chart' &&
        params[:action] != 'images' &&
        params[:action] != 'image' &&
        params[:action] != 'reset_index' &&
        params[:action] != 'contribute_tool_description' &&
        params[:format] != 'atom' &&
        !request.fullpath.match("#{request.script_name}/login") &&
        !request.fullpath.match("#{request.script_name}/join") &&
        !request.fullpath.match("#{request.script_name}/password") &&
        !request.fullpath.match("#{request.script_name}/sign_out") &&
        !request.xhr?) # don't store ajax calls
      store_location_in_session
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  # def after_sign_up_path_for(resource)
  #   session[:previous_url] || root_path
  # end

  def after_sign_out_path_for(resource_or_scope)
    session[:previous_url] || root_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :email, :password, :password_confirmation, :emails_enabled])
  end

  protected

  def store_location_in_session
    session[:previous_url] = request.fullpath
  end

  def check_community_manager
    redirect_to root_path, alert: 'You do not have sufficient privileges to access that page.' unless current_user.community_manager?
  end

  def check_system_admin
    redirect_to root_path, alert: 'You do not have sufficient privileges to access that page.' unless current_user.system_admin?
  end

  def scrub_order(model, params_order, default_order)
    (params_column, params_direction) = params_order.to_s.strip.downcase.split(' ')
    direction = (params_direction == 'desc' ? 'desc nulls last' : nil)
    column_name = model.column_names.collect { |c| "#{model.table_name}.#{c}" }.select { |c| c == params_column }.first
    order = column_name.blank? ? default_order : [column_name, direction].compact.join(' ')
    order
  end

  def check_banned
    return unless current_user.banned?
    flash[:warning] = 'You do not have permission to post on the forum.'
    empty_response_or_root_path(@topic || topics_path)
  end

  def parse_date(date_string, default_date = '')
    if date_string.to_s.split('/').last.size == 2
      Date.strptime(date_string, '%m/%d/%y')
    else
      Date.strptime(date_string, '%m/%d/%Y')
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
    user_id               = params[:auth_token].to_s.split('-').first.to_i
    auth_token            = params[:auth_token].to_s.gsub(/^#{user_id}-/, '')
    user                  = user_id && User.find_by_id(user_id)

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, auth_token)
      sign_in user, store: false
    end
  end

  def find_viewable_dataset_or_redirect(id = :dataset_id)
    viewable_datasets = if current_user
                          current_user.all_viewable_datasets
                        else
                          Dataset.current.where(public: true)
                        end
    @dataset = viewable_datasets.find_by_slug(params[id])
    redirect_without_dataset
  end

  def find_editable_dataset_or_redirect(id = :dataset_id)
    @dataset = current_user.all_datasets.find_by_slug(params[id]) if current_user
    redirect_without_dataset
  end

  def redirect_without_dataset
    empty_response_or_root_path(datasets_path) unless @dataset
  end

  def set_cache_buster
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

  def check_key_and_set_default_value(object, key, default_value)
    return unless params[object].key?(key) && params[object][key].blank?
    params[object][key] = default_value
  end

  def parse_date_if_key_present(object, key)
    return unless params[object].key?(key)
    params[object][key] = parse_date(params[object][key]) if params[object].key?(key)
  end

  def dataset_params
    params[:dataset] ||= { blank: '1' }
    params[:dataset][:release_date] = parse_date(params[:dataset][:release_date])
    params.require(:dataset).permit(
      :name, :description, :slug, :logo, :logo_cache, :public,
      :all_files_public, :git_repository, :release_date, :info_what, :info_who,
      :info_when, :info_funded_by, :info_citation, :info_size
      )
  end
end
