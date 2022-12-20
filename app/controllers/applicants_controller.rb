# frozen_string_literal: true

class ApplicantsController < ApplicationController
  layout 'dashboard', except: %i[new create]

  before_action :set_job
  before_action :authorize_user

  def index
    @users = Query::Applicant::Search.call(@job, params)
  end

  def show
    @applicant_user = @job.users.with_description_and_course_highlights.find(params[:id])
    applicant       = @job.applicants.find_by(job_id: @job.id, user_id: @applicant_user.id)

    @cover_letter = Query::Applicant::CoverLetter::Find.call(@applicant_user, applicant)
    @resume       = Query::Applicant::Resume::Find.call(user: @applicant_user, applicant:)

    Service::Applicant::Viewed.call(@job, @applicant_user, applicant)
  end

  def new
    @user      = User.with_description_and_course_highlights.find(current_user.id)
    @applicant = Applicant.new # required when we render from create action

    redirect_to @job.redirect_link if @job.redirect_link.present?
  end

  def create
    @user = if params[:resume_file] || params[:cover_letter_file]
              User.includes(resumes_attachments: :blob, cover_letters_attachments: :blob).find(params[:user_id])
            else
              User.find(params[:user_id])
            end

    @applicant = @job.applicants.build

    if params[:resume_file]
      if @user.resumes.attach(params[:resume_file])
        # @user.resumes.last is not reliable that why I am using order
        resume = @user.resumes.order(created_at: :desc).first
        @applicant.resume_name = "#{resume.filename} - #{resume.created_at.strftime('%d/%m/%Y')}"
        @user.delete_resumes_greater_than_10
      else
        @user.delete_resumes_with_id_nil
      end
    else
      @applicant.resume_name = params[:resume]
    end

    if params[:cover_letter_file]
      if @user.cover_letters.attach(params[:cover_letter_file])
        # @user.cover_letters.last is not reliable that why I am using order
        cover_letter = @user.cover_letters.order(created_at: :desc).first
        @applicant.cover_letter_name = "#{cover_letter.filename} - #{cover_letter.created_at.strftime('%d/%m/%Y')}"
        @user.delete_cover_letters_greater_than_10
      else
        @user.delete_cover_letters_with_id_nil
      end
    else
      @applicant.cover_letter_name = params[:cover_letter]
    end

    @applicant.user_id = @user.id
    @applicant.job_id = @job.id

    # @user.valid? return true and all error dissaper that's why I am using !@user.errors.present? to preserve previous error messages
    if !@user.errors.present? && @applicant.valid? && @applicant.save
      flash[:success] = 'Application Submitted.'
      ApplicantMailer.application_submitted(@user, @job, @applicant).deliver_later
      EmployerMailer.application_submitted(@job.user, @job, @user).deliver_later
      redirect_to root_path
    else
      render :new
    end
  end

  def shortlist
    applicant = @job.applicants.find_by(job_id: params[:job_id], user_id: params[:id])
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
    applicant = @job.applicants.find_by(job_id: params[:job_id], user_id: params[:id])
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
    resume = Query::Applicant::Resume::Find.call(job: @job, params:)
    return redirect_back_or_to job_applicants_path(@job), error: 'Unable to find Resume.' if resume.blank?

    send_data resume.download, filename: resume.filename.to_s
  end

  def download_cover_letter
    user = User.find(params[:id])
    applicant = @job.applicants.find_by(job_id: params[:job_id], user_id: params[:id])
    if applicant.cover_letter_name.present?
      cover_letter_name, cover_letter_date = applicant.cover_letter_name.split(' - ')
      cover_letter = user.cover_letters.order(created_at: :desc).includes(:blob).references(:blob)
                         .where(active_storage_blobs: { filename: cover_letter_name,
                                                        created_at: Date.parse(cover_letter_date).beginning_of_day..Date.parse(cover_letter_date).end_of_day }).first
      if cover_letter
        send_data cover_letter.download, filename: cover_letter.filename.to_s
      else
        flash[:error] = 'Unable to find Cover Letter.'
        redirect_to job_applicant_path(job, params[:id])
      end
    else
      flash[:error] = 'Unable to find Cover Letter.'
      redirect_to job_applicant_path(job, params[:id])
    end
  end

  private

  def set_job
    @job = Job.find(params[:job_id])
  end

  def authorize_user
    authorize @job, policy_class: ApplicantPolicy
  end
end
