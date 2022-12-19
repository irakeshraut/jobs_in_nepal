# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  skip_before_action :require_login

  def new; end

  def create
    @user = User.find_by_email(params[:email])
    @user&.deliver_reset_password_instructions!
    flash[:success] = 'Instructions have been sent to your email.'
    redirect_to(root_path)
  end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    not_authenticated if  @user.blank?
  end

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    not_authenticated and return if @user.blank?

    @user.password_confirmation = params[:password_confirmation]
    if @user.change_password(params[:password])
      flash[:success] = 'Password successfully updated.'
      redirect_to(root_path)
    else
      render :edit
    end
  end
end
