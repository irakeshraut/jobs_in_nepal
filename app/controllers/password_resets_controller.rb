class PasswordResetsController < ApplicationController
  skip_before_action :require_login
  
  def new
  end

  def create
    @user = User.find_by_email(params[:email])
    @user.deliver_reset_password_instructions! if @user
    flash[:success] = 'Instructions have been sent to your email.'
    redirect_to(root_path)
  end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end
  end

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end

    @user.password_confirmation = params[:password_confirmation]
    if @user.change_password(params[:password])
      flash[:success] = 'Passwrod successfully updated.'
      redirect_to(root_path)
    else
      render :edit
    end
  end
end
