class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_filter :store_location

  def store_location
    if (params[:action] != 'logo' &&
        params[:action] != 'files' &&
        params[:action] != 'variable_chart' &&
        !request.fullpath.match("#{request.script_name}/users/login") &&
        !request.fullpath.match("#{request.script_name}/users/register") &&
        !request.fullpath.match("#{request.script_name}/users/password") &&
        !request.fullpath.match("#{request.script_name}/auth/") &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  protected

  def check_system_admin
    redirect_to root_path, alert: "You do not have sufficient privileges to access that page." unless current_user.system_admin?
  end

  def empty_response_or_root_path(path = root_path)
    respond_to do |format|
      format.html { redirect_to path }
      format.js { render nothing: true }
      format.json { head :no_content }
      format.text { render nothing: true }
    end
  end

end
