# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new; end

  def create
    user     = login(params[:email], params[:password])
    @service = Service::Session::Create.call(user, params)

    @service.success? ? redirect_back_or_to(root_path) : (render :new)
  end

  def destroy
    logout
    redirect_to(login_path)
  end
end
