class ApplicantsController < ApplicationController
  layout 'dashboard', except: [:new, :create]

  def index
    @job = Job.find(params[:job_id])
    @users = @job.users.includes([:avatar_attachment])
    @users = @users.filter_by_name(params[:name]) if params[:name].present?
    @users = @users.filter_by_status(params[:status]) if params[:status].present?
    @users = @users.paginate(page: params[:page], per_page: 30)
  end

  def new
    @job = Job.find(params[:job_id])
    @user = current_user
    authorize @job, policy_class: ApplicantPolicy
    @error_messages = params[:error_messages] if params[:error_messages]
    if @job.redirect_link.present?
      redirect_to @job.redirect_link
    end
  end

  def create
    @job = Job.find(params[:job_id])
    @user = current_user
    authorize @job, policy_class: ApplicantPolicy
    applicant = @job.applicants.build

    if params[:resume_file]
      if @user.resumes.attach(params[:resume_file])
        applicant.resume_name = "#{@user.resumes.last.filename.to_s} - #{@user.resumes.last.created_at.strftime("%d/%m/%Y")}"
      end
    else
      applicant.resume_name = params[:resume]
    end

    if params[:cover_letter_file]
      if @user.cover_letters.attach(params[:cover_letter_file])
        applicant.cover_letter_name = "#{@user.cover_letters.last.filename.to_s} - #{@user.cover_letters.last.created_at.strftime("%d/%m/%Y")}"
      end
    else
      applicant.cover_letter_name = params[:cover_letter]
    end

    applicant.user_id = @user.id
    applicant.job_id = @job.id

    if @user.valid? && applicant.valid? && applicant.save
      flash[:success] = 'Application Submitted.'
      redirect_to root_path
    else
      redirect_to new_job_applicant_path(@job, error_messages: @user.errors.full_messages + applicant.errors.full_messages)
    end
  end

  def shortlist
    job = Job.find(params[:job_id])
    applicant = job.applicants.find_by(job_id: params[:job_id], user_id: params[:id])
    if applicant.update(status: 'Shortlisted')
      flash[:success] = 'Applicant Shortlisted.'
      redirect_to job_applicants_path(params[:job_id])
    else
      flash[:error] = 'Something went wrong'
      redirect_to job_applicants_path(params[:job_id])
    end
  end

  def reject
    job = Job.find(params[:job_id])
    applicant = job.applicants.find_by(job_id: params[:job_id], user_id: params[:id])
    if applicant.update(status: 'Rejected')
      flash[:success] = 'Applicant Rejected.'
      redirect_to job_applicants_path(params[:job_id])
    else
      flash[:error] = 'Something went wrong'
      redirect_to job_applicants_path(params[:job_id])
    end
  end

  def download_resume
    job = Job.find(params[:job_id])
    user = User.find(params[:id])
    applicant = job.applicants.find_by(job_id: params[:job_id], user_id: params[:id])
    resume_name, resume_date = applicant.resume_name.split(' - ')
    resume = user.resumes.includes(:blob).references(:blob)
      .where(active_storage_blobs: { filename: resume_name, created_at: Date.parse(resume_date).beginning_of_day..Date.parse(resume_date).end_of_day }).last
    if resume
      send_data resume.download, filename: resume.filename.to_s
    else
      flash[:error] = "Unable to find Resume."
      redirect_to job_applicants_path(params[:job_id])
    end
  end
end
