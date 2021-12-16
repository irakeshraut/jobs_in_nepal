class DashboardsController < ApplicationController
  layout 'dashboard'

  def index
    @user = current_user
    @applied_jobs = @user.applied_jobs.includes(:user).order(created_at: :desc).take(10)
  end
end
