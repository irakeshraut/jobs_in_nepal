class JobsController < ApplicationController
  layout 'dashboard', except: [:index, :show]
  skip_before_action :require_login, only: [:index, :show]

  def index
    @jobs = Job.includes(user: { company: [logo_attachment: :blob] }).active.order(created_at: :desc)
    @jobs = @jobs.filter_by_title(params[:title]) if params[:title].present?
    @jobs = @jobs.filter_by_category(params[:category]) if params[:category].present?
    @jobs = @jobs.filter_by_location(params[:location]) if params[:location].present?
    @jobs = @jobs.paginate(page: params[:page], per_page: 30)
  end

  def show
    @job = Job.find(params[:id])
    if @job.views.where(ip: request.remote_ip).created_today.empty?
      @job.views.create(ip: request.remote_ip)
    end
    @similar_jobs = @job.similar_jobs.shuffle.take(4)
  end

  def new
    @job = Job.new
    authorize @job
  end

  def create
    @job = Job.new(job_params)
    authorize @job
    @job.status = 'Active'
    @job.user_id = current_user.id
    if @job.valid? && @job.save
      flash[:success] = 'Job Posted'
      redirect_to user_dashboards_path(current_user)
    else
      render :new
    end
  end

  def edit
    @job = Job.find(params[:id])
    authorize @job
  end

  def update
    @job = Job.find(params[:id])
    authorize @job
    if @job.update(job_params)
      flash[:success] = 'Job updated successfully.'
      redirect_to edit_job_path(@job)
    else
      render :edit
    end
  end

  def destroy
    job = Job.find(params[:id])
    authorize job
    job.destroy
    flash[:success] = 'Job Deleted.'
    redirect_to all_posted_jobs_user_path(current_user)
  end

  def close_job
    job = Job.find(params[:id])
    authorize job
    job.status = 'Closed'
    job.save
    flash[:success] = 'Job has been closed.'
    redirect_to job
  end

  def reopen_job
    job = Job.find(params[:id])
    authorize job
    job.status = 'Active'
    job.save
    flash[:success] = 'Job has been Re-opened.'
    redirect_to job
  end

  private

  def job_params
    params.require(:job).permit(:title, :category, :location, :min_salary, :max_salary, 
                                :employment_type, :description, :redirect_link, :company_name)
  end
end
