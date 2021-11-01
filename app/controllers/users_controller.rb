class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    @user = User.new
    @company = Company.new
    @tab = params[:tab] if params[:tab]
    @error_messages = params[:error_messages] if params[:error_messages]
  end 

  def create
    @user = User.new(user_params)
    @user.role = 'job_seeker'
    @company = Company.new
    if @user.valid? && @user.save
      redirect_to root_path
    else
      redirect_to new_user_path(tab: 'job_seeker', error_messages: @user.errors.full_messages)
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end
