# This controller handles easy registration/sign in of users as part of a tool
# contribution or request, or a dataset hosting request.
class RequestController < ApplicationController
  def tool_contribute
    @tool = Tool.new
  end

  def create_tool_contribute
    @tool = Tool.new(tool_contribute_params)
    unless current_user
      user = User.new(user_params)
      if user.save
        # TODO: Send email of account creation with temporary password
        # UserMailer.tool_contribute_account_created(params[:user][:password]).deliver!
        sign_in(:user, user)
      else
        @errors = user.errors
        render :tool_contribute
        return
      end
    end

    @tool.user_id = current_user.id
    if @tool.save
      redirect_to tool_contribute_submitted_path
    else
      render :tool_contribute
    end
  end

  def tool_contribute_submitted
  end

  def tool_request
  end

  def dataset_hosting
    @hosting_request = HostingRequest.new
  end

  def create_hosting_request
    @hosting_request = HostingRequest.new(hosting_request_params)
    unless current_user
      user = User.new(user_params)
      if user.save
        # TODO: Send email of account creation with temporary password
        # UserMailer.hosting_request_account_created(params[:user][:password]).deliver!
        sign_in(:user, user)
      else
        @errors = user.errors
        render :dataset_hosting
        return
      end
    end

    @hosting_request.user_id = current_user.id
    if @hosting_request.save
      redirect_to dataset_hosting_submitted_path
    else
      render :dataset_hosting
    end
  end

  def dataset_hosting_submitted
  end

  private

  def tool_contribute_params
    params.require(:tool).permit(:description, :url)
  end

  def hosting_request_params
    params.require(:hosting_request).permit(:description, :institution_name)
  end

  def user_params
    params[:user] ||= {}
    params[:user][:password] = params[:user][:password_confirmation] = SecureRandom.hex(8)
    params.require(:user).permit(
      :first_name, :last_name, :email,
      :password, :password_confirmation)
  end
end
