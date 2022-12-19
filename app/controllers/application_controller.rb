# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  before_action :require_login
  before_action :set_top_categories
  before_action :redirect_www_to_non_www

  rescue_from Pundit::NotAuthorizedError do
    flash[:error] = 'You are not authorized to perform this action.'
    redirect_back(fallback_location: root_path)
  end

  def set_top_categories
    @top_categories = Job.group(:category).order('count_all desc').count.keys.take(5)
  end

  private

  def redirect_www_to_non_www
    redirect_to "https://jobsinnepal.com#{request.fullpath}", status: 301 if request.host == 'www.jobsinnepal.com'
  end

  def not_authenticated
    redirect_to login_path, success: 'Please login first'
  end
end
