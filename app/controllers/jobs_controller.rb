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
    unless @job.views.find_by(ip: request.remote_ip)
      @job.views.create(ip: request.remote_ip)
    end
    @similar_jobs = @job.similar_jobs.take(4)
  end
  
  def new
    @job = Job.new
    authorize @job
    @error_messages = params[:error_messages] if params[:error_messages]
  end

  def create
    @job = Job.new(job_params)
    authorize @job
    @job.status = 'Active'
    @job.user_id = current_user.id
    if @job.valid? && @job.save
      redirect_to user_dashboards_path(current_user)
    else
      redirect_to new_job_path(error_messages: @job.errors.full_messages)
    end
  end

  def edit
    @job = Job.find(params[:id])
    authorize @job
    @error_messages = params[:error_messages] if params[:error_messages]
  end

  def update
    @job = Job.find(params[:id])
    authorize @job
    if @job.update(job_params)
      flash[:success] = 'Job updated successfully.'
      redirect_to edit_job_path(@job)
    else
      redirect_to edit_job_path(@job, error_messages: @job.errors.full_messages)
    end
  end

  def destroy
    job = Job.find(params[:id])
    authorize job
    job.destroy
    flash[:success] = 'Job Deleted.'
    redirect_to all_posted_jobs_jobs_path
  end

  private

  def job_params
    params.require(:job).permit(:title, :category, :location, :min_salary, :max_salary, 
                                :employment_type, :description, :redirect_link, :company_name)
  end
end
