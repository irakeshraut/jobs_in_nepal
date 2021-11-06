class JobsController < ApplicationController
  layout 'dashboard', except: [:index, :show]

  def index
    @jobs = Job.active.order('created_at DESC')
    @jobs = @jobs.filter_by_title(params[:title]) if params[:title].present?
    @jobs = @jobs.filter_by_category(params[:category]) if params[:category].present?
    @jobs = @jobs.filter_by_location(params[:location]) if params[:location].present?
  end

  def show
    @job = Job.find(params[:id])
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
      redirect_to dashboards_path
    else
      redirect_to new_job_path(error_messages: @job.errors.full_messages)
    end
  end

  private

  def job_params
    params.require(:job).permit(:title, :category, :location, :min_salary, :max_salary, 
                                :employment_type, :description, :redirect_link, :company_name)
  end
end
