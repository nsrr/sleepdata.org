class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = User.current.search(params[:search]).order(current_sign_in_at: :desc).page(params[:page]).per( 40 )
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  private

    def set_user
      @user = User.current.find_by_id(params[:id])
    end

    def redirect_without_user
      empty_response_or_root_path(users_path) unless @user
    end

    def user_params
      params[:user] ||= {}

      if current_user.system_admin?
        params.require(:user).permit(
          :first_name, :last_name, :email, :research_summary, :degree, :aug_member, :core_member, :system_admin
        )
      else
        params.require(:user).permit(
          :first_name, :last_name, :email, :research_summary
        )
      end
    end

end
