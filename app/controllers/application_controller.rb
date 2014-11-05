class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :store_location

  def store_location
    if (params[:action] != 'logo' &&
        params[:action] != 'files' &&
        params[:action] != 'variable_chart' &&
        params[:action] != 'images' &&
        params[:action] != 'image' &&
        params[:action] != 'reset_index' &&
        !request.fullpath.match("#{request.script_name}/users/login") &&
        !request.fullpath.match("#{request.script_name}/users/register") &&
        !request.fullpath.match("#{request.script_name}/users/password") &&
        !request.fullpath.match("#{request.script_name}/users/sign_out") &&
        !request.fullpath.match("#{request.script_name}/auth/") &&
        !request.xhr?) # don't store ajax calls
      store_location_in_session
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    session[:previous_url] || root_path
  end

  protected

  def store_location_in_session
    session[:previous_url] = request.fullpath
  end

  def check_system_admin
    redirect_to root_path, alert: "You do not have sufficient privileges to access that page." unless current_user.system_admin?
  end

  def scrub_order(model, params_order, default_order)
    (params_column, params_direction) = params_order.to_s.strip.downcase.split(' ')
    direction = (params_direction == 'desc' ? 'DESC NULLS LAST' : nil)
    column_name = (model.column_names.collect{|c| model.table_name + "." + c}.select{|c| c == params_column}.first)
    order = column_name.blank? ? default_order : [column_name, direction].compact.join(' ')
    order
  end

  def check_banned
    if current_user.banned?
      flash[:warning] = "You do not have permission to post on the forum."
      empty_response_or_root_path(@topic || topics_path)
    end
  end

  def parse_date(date_string, default_date = '')
    date_string.to_s.split('/').last.size == 2 ? Date.strptime(date_string, "%m/%d/%y") : Date.strptime(date_string, "%m/%d/%Y") rescue default_date
  end

  def empty_response_or_root_path(path = root_path)
    respond_to do |format|
      format.html { redirect_to path }
      format.js { render nothing: true }
      format.json { head :no_content }
      format.text { render nothing: true }
    end
  end

  def authenticate_user_from_token!
    user_id               = params[:auth_token].to_s.split('-').first
    auth_token            = (params[:auth_token].to_s.split('-')[1..-1] || []).join('-')
    user                  = user_id && User.find_by_id(user_id)

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, auth_token)
      sign_in user, store: false
    end
  end

  def set_viewable_dataset(id = :dataset_id)
    viewable_datasets = if current_user
      current_user.all_viewable_datasets
    else
      Dataset.current.where( public: true )
    end
    @dataset = viewable_datasets.find_by_slug(params[id])
  end

  def set_editable_dataset(id = :dataset_id)
    @dataset = current_user.all_datasets.find_by_slug(params[id]) if current_user
  end

  def redirect_without_dataset
    empty_response_or_root_path( datasets_path ) unless @dataset
  end

end
