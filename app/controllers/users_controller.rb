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
    authorize @user
    @error_messages = params[:error_messages] if params[:error_messages]
    @hide_error_messages = params[:hide_error_messages] if params[:hide_error_messages]
  end

  def update
    @user = User.find(params[:id])
    authorize @user
    if @user.update_attributes(edit_user_params)
      flash[:success] = 'User Profile Successfully Updated.'
      redirect_to dashboards_path
    else
      redirect_to edit_user_path(@user, error_messages: @user.errors.full_messages)
    end
  end

  def update_password
    old_current_user = current_user # need to set current_user before using login otherwise current_user will be nil when login fail.
    @user = login(old_current_user.email, params[:current_password])
    authorize @user

    if @user
      if @user.update_attributes(password_params)
        flash[:success] = 'Password Successfully Updated.'
        redirect_to dashboards_path
      else
        redirect_to edit_user_path(@user, error_messages: @user.errors.full_messages, hide_error_messages: true)
      end
    else
      flash[:error] = 'Invalid Current Password.'
      redirect_to edit_user_path(old_current_user)
    end
  end

  private

  def password_params
    params.permit(:password, :password_confirmation)
  end

  def edit_user_params
    params.require(:user).permit(:first_name, :last_name, :email)
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end
