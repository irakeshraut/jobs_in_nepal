class ApplicantsController < ApplicationController
  layout 'dashboard', except: [:new, :create]

  def index
    @job = Job.find(params[:job_id])
    authorize @job, policy_class: ApplicantPolicy
    @users = @job.users.includes([:avatar_attachment])
    @users = @users.filter_by_name(params[:name]) if params[:name].present?
    @users = @users.filter_by_status(params[:status]) if params[:status].present?
    @users = @users.paginate(page: params[:page], per_page: 30)
  end

  def show
    @job = Job.find(params[:job_id])
    authorize @job, policy_class: ApplicantPolicy
    @applicant_user = @job.users.find(params[:id])
    applicant = @job.applicants.find_by(job_id: @job.id, user_id: @applicant_user.id)
    if applicant.cover_letter_name.present?
      cover_letter_name, cover_letter_date = applicant.cover_letter_name.split(' - ')
      @cover_letter = @applicant_user.cover_letters.includes(:blob).references(:blob)
        .where(active_storage_blobs: { filename: cover_letter_name, created_at: Date.parse(cover_letter_date).beginning_of_day..Date.parse(cover_letter_date).end_of_day }).last
    end
    if applicant.resume_name.present?
      resume_name, resume_date = applicant.resume_name.split(' - ')
      @resume = @applicant_user.resumes.includes(:blob).references(:blob)
        .where(active_storage_blobs: { filename: resume_name, created_at: Date.parse(resume_date).beginning_of_day..Date.parse(resume_date).end_of_day }).last
    end
    if applicant.viewed_by_employer == false
      applicant.viewed_by_employer = true
      applicant.save!
      ApplicantMailer.application_viewed(@applicant_user, @job, applicant).deliver_later
    end
  end

  def new
    @job = Job.find(params[:job_id])
    @user = current_user
    @applicant = Applicant.new # required when we render from create action
    authorize @job, policy_class: ApplicantPolicy
    if @job.redirect_link.present?
      redirect_to @job.redirect_link
    end
  end

  def create
    @job = Job.find(params[:job_id])
    @user = current_user
    authorize @job, policy_class: ApplicantPolicy
    @applicant = @job.applicants.build

    if params[:resume_file]
      if @user.resumes.count >= 10
        @user.resumes.order(:created_at).first.purge
      end
      if @user.resumes.attach(params[:resume_file])
        @applicant.resume_name = "#{@user.resumes.last.filename.to_s} - #{@user.resumes.last.created_at.strftime("%d/%m/%Y")}"
      end
    else
      @applicant.resume_name = params[:resume]
    end

    if params[:cover_letter_file]
      if @user.cover_letters.count >= 10
        @user.cover_letters.order(:created_at).first.purge
      end
      if @user.cover_letters.attach(params[:cover_letter_file])
        @applicant.cover_letter_name = "#{@user.cover_letters.last.filename.to_s} - #{@user.cover_letters.last.created_at.strftime("%d/%m/%Y")}"
      end
    else
      @applicant.cover_letter_name = params[:cover_letter]
    end

    @applicant.user_id = @user.id
    @applicant.job_id = @job.id

    if @user.valid? && @applicant.valid? && @applicant.save
      flash[:success] = 'Application Submitted.'
      ApplicantMailer.application_submitted(@user, @job, @applicant).deliver_later
      redirect_to root_path
    else
      render :new
    end
  end

  def shortlist
    job = Job.find(params[:job_id])
    authorize job, policy_class: ApplicantPolicy
    applicant = job.applicants.find_by(job_id: params[:job_id], user_id: params[:id])
    if applicant.update(status: 'Shortlisted')
      flash[:success] = 'Applicant Shortlisted.'
    else
      flash[:error] = 'Something went wrong'
    end

    if params[:redirect_back] == 'job_applicant_path'
      redirect_to job_applicant_path(job, params[:id])
    else
      redirect_to job_applicants_path(params[:job_id])
    end
  end

  def reject
    job = Job.find(params[:job_id])
    authorize job, policy_class: ApplicantPolicy
    applicant = job.applicants.find_by(job_id: params[:job_id], user_id: params[:id])
    if applicant.update(status: 'Rejected')
      flash[:success] = 'Applicant Rejected.'
    else
      flash[:error] = 'Something went wrong'
    end

    if applicant.rejected_email_sent == false
      applicant.rejected_email_sent = true
      applicant.save!
      ApplicantMailer.application_rejected(job, applicant).deliver_later
    end

    if params[:redirect_back] == 'job_applicant_path'
      redirect_to job_applicant_path(job, params[:id])
    else
      redirect_to job_applicants_path(params[:job_id])
    end
  end

  def download_resume
    job = Job.find(params[:job_id])
    authorize job, policy_class: ApplicantPolicy
    user = User.find(params[:id])
    applicant = job.applicants.find_by(job_id: params[:job_id], user_id: params[:id])
    resume_name, resume_date = applicant.resume_name.split(' - ')
    resume = user.resumes.includes(:blob).references(:blob)
      .where(active_storage_blobs: { filename: resume_name, created_at: Date.parse(resume_date).beginning_of_day..Date.parse(resume_date).end_of_day }).last
    if resume
      send_data resume.download, filename: resume.filename.to_s
    else
      flash[:error] = "Unable to find Resume."
      if params[:redirect_back] == 'job_applicant_path'
        redirect_to job_applicant_path(job, params[:id])
      else
        redirect_to job_applicants_path(params[:job_id])
      end
    end
  end

  def download_cover_letter
    job = Job.find(params[:job_id])
    authorize job, policy_class: ApplicantPolicy
    user = User.find(params[:id])
    applicant = job.applicants.find_by(job_id: params[:job_id], user_id: params[:id])
    if applicant.cover_letter_name.present?
      cover_letter_name, cover_letter_date = applicant.cover_letter_name.split(' - ')
      cover_letter = user.cover_letters.includes(:blob).references(:blob)
        .where(active_storage_blobs: { filename: cover_letter_name, created_at: Date.parse(cover_letter_date).beginning_of_day..Date.parse(cover_letter_date).end_of_day }).last
      if cover_letter
        send_data cover_letter.download, filename: cover_letter.filename.to_s
      else
        flash[:error] = "Unable to find Cover Letter."
        redirect_to job_applicant_path(job, params[:id])
      end
    else
      flash[:error] = "Unable to find Cover Letter."
      redirect_to job_applicant_path(job, params[:id])
    end
  end
end
