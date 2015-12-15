# This controller handles easy registration/sign in of users as part of a tool
# contribution or request, or a dataset hosting request.
class RequestController < ApplicationController
  before_action :authenticate_user!, only: [:contribute_tool_description, :contribute_tool_set_description]

  def contribute_tool_start
    @community_tool = CommunityTool.new
  end

  def contribute_tool_set_location
    @community_tool = CommunityTool.new(url: params[:community_tool][:url].strip)
    @community_tool.valid?
    if @community_tool.errors[:url].present?
      render :contribute_tool_start
    else
      if current_user
        save_tool_user
      else
        render :contribute_tool_about_me
      end
    end
  end

  def contribute_tool_about_me
    @community_tool = CommunityTool.new(url: params[:url])
  end

  def contribute_tool_register_user
    @community_tool = CommunityTool.new(url: params[:community_tool][:url])
    unless current_user
      user = User.new(user_params)
      if user.save
        sign_in(:user, user)
      else
        @registration_errors = user.errors
        render :contribute_tool_about_me
        return
      end
    end

    save_tool_user
  end

  def contribute_tool_sign_in_user
    @community_tool = CommunityTool.new(url: params[:community_tool][:url])
    unless current_user
      user = User.find_by_email params[:email]
      if user && user.valid_password?(params[:password])
        sign_in(:user, user)
      else
        @sign_in_errors = []
        @sign_in = true
        render :contribute_tool_about_me
        return
      end
    end

    save_tool_user
  end

  def contribute_tool_description
    @community_tool = current_user.community_tools.where(status: 'started').find_by_id params[:id]
    redirect_to dashboard_path, alert: 'This tool does not exist.' unless @community_tool
  end

  def contribute_tool_set_description
    @community_tool = current_user.community_tools.where(status: 'started').find_by_id params[:id]
    unless @community_tool
      redirect_to dashboard_path, alert: 'This tool does not exist.'
      return
    end

    status = (params[:draft] == '1' ? 'started' : 'submitted')

    if @community_tool.update(name: params[:community_tool][:name], description: params[:community_tool][:description], status: status)
      if status == 'started'
        redirect_to dashboard_path, notice: 'Draft saved successfully.'
      else
        redirect_to contribute_tool_submitted_path
      end
    else
      render :contribute_tool_description
    end
  end

  def tool_contribute
    @community_tool = CommunityTool.new
  end

  def create_tool_contribute
    @community_tool = CommunityTool.new(community_tool_params)
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

    @community_tool.user_id = current_user.id
    if @community_tool.save
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

  def community_tool_params
    params.require(:community_tool).permit(:description, :url)
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

  def save_tool_user
    @community_tool.user_id = current_user.id
    if @community_tool.save
      description = @community_tool.readme_content
      if description
        description = "```\n#{description}\n```" unless @community_tool.markdown?
        @community_tool.update description: description
      end
      redirect_to contribute_tool_description_path(@community_tool)
    else
      render :contribute_tool_start
    end
  end
end
