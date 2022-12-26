# frozen_string_literal: true

class DashboardsController < ApplicationController
  layout 'dashboard'

  before_action :set_user
  before_action :authorize_user

  def index
    setup_job_seeker and return if @user.job_seeker?

    @active_jobs  = @user.jobs.active.order(created_at: :desc).take(10)
    @closed_jobs  = @user.jobs.closed.order(created_at: :desc).take(10)
    @expired_jobs = @user.jobs.expired.order(created_at: :desc).take(10)
  end

  def jobs_posted_by_employers_today
    @jobs = Job.created_by_employers.created_today.with_company_logo.order(created_at: :desc)
    filter_jobs
  end

  def all_jobs_by_admin_and_employer
    @jobs = Job.with_company_logo.order(created_at: :desc)
    filter_jobs
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def authorize_user
    authorize @user, policy_class: DashboardPolicy
  end

  def filter_jobs
    title  = params[:title]
    status = params[:status]

    @jobs = @jobs.filter_by_title(title) if title.present?
    @jobs = @jobs.filter_by_status(status) if status.present?
    @jobs = @jobs.paginate(page: params[:page], per_page: 30)
  end

  def setup_job_seeker
    @user = User.with_education.with_work_experience.find(params[:user_id])
    @applied_jobs = @user.applied_jobs.with_company_logo.order(created_at: :desc).take(10)
  end
end
