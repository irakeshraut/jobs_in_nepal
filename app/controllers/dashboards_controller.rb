# frozen_string_literal: true

class DashboardsController < ApplicationController
  layout 'dashboard'

  def index
    @user = User.find(params[:user_id])
    if @user.job_seeker?
      @user = User.includes(educations: :rich_text_course_highlights,
                            work_experiences: :rich_text_description).find(params[:user_id])
    end
    authorize @user, policy_class: DashboardPolicy
    if @user.job_seeker?
      @applied_jobs = @user.applied_jobs.includes(user: { company: [logo_attachment: :blob] }).order(created_at: :desc).take(10)
    end
    return unless @user.employer? || @user.admin?

    @active_jobs = @user.jobs.active.order(created_at: :desc).take(10)
    @closed_jobs = @user.jobs.closed.order(created_at: :desc).take(10)
    @expired_jobs = @user.jobs.expired.order(created_at: :desc).take(10)
  end

  def jobs_posted_by_employers_today
    @user = User.find(params[:user_id])
    authorize @user, policy_class: DashboardPolicy
    @jobs = Job.created_by_employers.created_today.order(created_at: :desc)
               .includes(user: { company: [logo_attachment: :blob] })
    @jobs = @jobs.filter_by_title(params[:title]) if params[:title].present?
    @jobs = @jobs.filter_by_status(params[:status]) if params[:status].present?
    @jobs = @jobs.paginate(page: params[:page], per_page: 30)
  end

  def all_jobs_posted_by_admin_and_employers
    @user = User.find(params[:user_id])
    authorize @user, policy_class: DashboardPolicy
    @jobs = Job.all.order(created_at: :desc).includes(user: { company: [logo_attachment: :blob] })
    @jobs = @jobs.filter_by_title(params[:title]) if params[:title].present?
    @jobs = @jobs.filter_by_status(params[:status]) if params[:status].present?
    @jobs = @jobs.paginate(page: params[:page], per_page: 30)
  end
end
