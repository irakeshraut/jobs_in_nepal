# frozen_string_literal: true

class JobsController < ApplicationController
  layout 'dashboard', except: %i[index show]
  skip_before_action :require_login, only: %i[index show]

  before_action :set_job, except: %i[index new create]
  before_action :authorize_user, except: %i[index show]

  def index
    @jobs = Query::Job::Search.call(params)
    @category_count = @jobs.filter_by_category(params[:category]).count if params[:category].present?
  end

  def show
    @job.views.create(ip: request.remote_ip) if @job.views.where(ip: request.remote_ip).created_today.empty?
    @similar_jobs = @job.similar_jobs
  end

  def new
    @job = Job.new
  end

  def create
    @job = Job.new(job_params)
    authorize @job

    @job.attributes = { status: 'Active', user_id: current_user.id, job_type: 3 }

    if @job.valid? && @job.save
      flash[:success] = 'Job Posted'
      redirect_to user_dashboards_path(current_user)
    else
      render :new
    end
  end

  def edit; end

  def update
    if @job.update(job_params)
      flash[:success] = 'Job updated successfully.'
      redirect_to edit_job_path(@job)
    else
      render :edit
    end
  end

  def destroy
    @job.destroy
    flash[:success] = 'Job Deleted.'

    redirect_to all_posted_jobs_user_path(current_user)
  end

  def close_job
    @job.update!(status: 'Closed')
    flash[:success] = 'Job has been closed.'

    redirect_to @job
  end

  def reopen_job
    @job.update!(status: 'Active')
    flash[:success] = 'Job has been Re-opened.'

    redirect_to @job
  end

  def closed_by_admin
    @job.update!(status: 'Closed', closed_by_admin: true)
    flash[:success] = 'Job has been closed by Admin.'

    redirect_to @job
  end

  def reopened_by_admin
    @job.update!(status: 'Active', closed_by_admin: nil)
    flash[:success] = 'Job has been Re-opened by Admin.'

    redirect_to @job
  end

  private

  def set_job
    @job = Job.find(params[:id])
  end

  def authorize_user
    authorize @job
  end

  def job_params
    params.require(:job).permit(:title, :category, :location, :min_salary, :max_salary,
                                :employment_type, :description, :redirect_link, :company_name)
  end
end
