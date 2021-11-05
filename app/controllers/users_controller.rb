class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  layout 'dashboard', only: [:edit, :update]

  def new
    @user = User.new
    @company = Company.new
    @tab = params[:tab] if params[:tab]
    @error_messages = params[:error_messages] if params[:error_messages]
    unless @tab
      redirect_to new_user_path(tab: 'job_seeker')
    end
  end 

  def create
    @user = User.new(user_params)
    @user.role = 'job_seeker'
    @company = Company.new
    if @user.valid? && @user.save
      redirect_to login_path
    else
      redirect_to new_user_path(tab: 'job_seeker', error_messages: @user.errors.full_messages)
    end
  end

  def edit
    @user = User.find(params[:id])
    @error_messages = params[:error_messages] if params[:error_messages]
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(edit_user_params)
      flash[:success] = 'User Profile Sucessfully Updated.'
      redirect_to dashboards_path
    else
      redirect_to edit_user_path(@user, error_messages: @user.errors.full_messages)
    end
  end

  private

  def edit_user_params
    params.require(:user).permit(:first_name, :last_name, :email)
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end
