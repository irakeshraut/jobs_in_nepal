class DashboardsController < ApplicationController
  layout 'dashboard'

  def index
    @user = User.find(params[:user_id])
    authorize @user, policy_class: DashboardPolicy
    @applied_jobs = @user.applied_jobs.includes(:user).order(created_at: :desc).take(10)
  end
end
