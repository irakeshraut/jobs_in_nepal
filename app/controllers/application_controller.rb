class ApplicationController < ActionController::Base
  include Pundit
  before_action :require_login

  rescue_from Pundit::NotAuthorizedError do
    flash[:error] = "You are not authorized to perform this action."
    redirect_to root_path
  end

  private

  def not_authenticated
    redirect_to login_path, success: "Please login first"
  end
end
