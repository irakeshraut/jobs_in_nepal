class JobsController < ApplicationController
  layout 'dashboard', except: [:index, :show]
  skip_before_action :require_login, only: [:index, :show]

  def index
    @jobs = Job.active.order(job_type: :asc, created_at: :desc).limit(48)
    created_by_employer = @jobs.created_by_employers
    if created_by_employer.present?
      @jobs = @jobs.includes(user: { company: [logo_attachment: :blob] })
    end
    @jobs = @jobs.filter_by_title(params[:title]) if params[:title].present?
    @jobs = @jobs.filter_by_category(params[:category]) if params[:category].present?
    @jobs = @jobs.filter_by_location(params[:location]) if params[:location].present?
    @jobs = @jobs.paginate(page: params[:page], per_page: 30)
    @category_count = @jobs.filter_by_category(params[:category]).count if params[:category].present?
  end

  def show
    @job = Job.find(params[:id])
    if @job.views.where(ip: request.remote_ip).created_today.empty?
      @job.views.create(ip: request.remote_ip)
    end
    @similar_jobs = @job.similar_jobs
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
    # TODO: remove below code of setting job_type when we start taking payments and put options for job type in job new form
    if @job.created_by_employer?
      @job.job_type = 1 # Top Job
    else
      @job.job_type = 3 # Normal Job(created by Admin)
    end
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

  def closed_by_admin
    job = Job.find(params[:id])
    authorize job
    job.status = 'Closed'
    job.closed_by_admin = true
    job.save
    flash[:success] = 'Job has been closed by Admin.'
    redirect_to job
  end

  def reopened_by_admin
    job = Job.find(params[:id])
    authorize job
    job.status = 'Active'
    job.closed_by_admin = nil
    job.save
    flash[:success] = 'Job has been Re-opened by Admin.'
    redirect_to job
  end

  private

  def job_params
    params.require(:job).permit(:title, :category, :location, :min_salary, :max_salary, 
                                :employment_type, :description, :redirect_link, :company_name)
  end
end
