# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  skip_before_action :require_login
  before_action :set_token, only: %i[edit update]
  before_action :set_user, only: %i[edit update]
  before_action :authenticate_user, only: %i[edit update]

  def new; end

  def create
    @user = User.find_by_email(params[:email])
    @user&.deliver_reset_password_instructions!
    flash[:success] = 'Instructions have been sent to your email.'
    redirect_to(root_path)
  end

  def edit; end

  def update
    @user.password_confirmation = params[:password_confirmation]

    if @user.change_password(params[:password])
      flash[:success] = 'Password successfully updated.'
      redirect_to(root_path)
    else
      render :edit
    end
  end

  private

  def set_token
    @token = params[:id]
  end

  def set_user
    @user = User.load_from_reset_password_token(params[:id])
  end

  def authenticate_user
    not_authenticated and return if @user.blank?
  end
end
