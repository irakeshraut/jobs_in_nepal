class ApplicationController < ActionController::Base
  include Pundit
  before_action :require_login
  before_action :set_top_categories

  rescue_from Pundit::NotAuthorizedError do
    flash[:error] = "You are not authorized to perform this action."
    redirect_to root_path
  end

  def set_top_categories
    @top_categories = Job.group(:category).order('count_all desc').count.keys.take(5) 
  end

  private

  def not_authenticated
    redirect_to login_path, success: "Please login first"
  end
end
