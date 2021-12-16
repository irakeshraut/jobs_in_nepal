class DashboardsController < ApplicationController
  layout 'dashboard'

  def index
    @user = User.find(params[:user_id])
    authorize @user, policy_class: DashboardPolicy
    @applied_jobs = @user.applied_jobs.includes(:user).order(created_at: :desc).take(10) if current_user.job_seeker?
    if current_user.employer?
      @active_jobs = @user.jobs.active.order(created_at: :desc).take(10)
      @expired_jobs = @user.jobs.expired.order(created_at: :desc).take(10)
    end
  end
end
