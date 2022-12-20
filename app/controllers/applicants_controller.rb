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
    applicant       = @job.applicants.find_by(user_id: @applicant_user.id)

    @cover_letter = Query::Applicant::CoverLetter::Find.call(user: @applicant_user, applicant:)
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
        cover_letter = @user.resumes.order(created_at: :desc).first
        @applicant.resume_name = "#{cover_letter.filename} - #{cover_letter.created_at.strftime('%d/%m/%Y')}"
        @user.delete_resumes_greater_than_10
      else
        @user.delete_resumes_with_id_nil
      end
    else
      @applicant.resume_name = params[:cover_letter]
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
    # applicant = @job.applicants.find_by(user_id: params[:id])
    # if applicant.update(status: 'Shortlisted')
    #   flash[:success] = 'Applicant Shortlisted.'
    # else
    #   flash[:error] = 'Something went wrong'
    # end
    #
    # if params[:redirect_back] == 'job_applicant_path'
    #   redirect_to job_applicant_path(job, params[:id])
    # else
    #   redirect_to job_applicants_path(params[:job_id])
    # end

    service = Service::Applicant::Shortlist.call(@job, params)
    flash[:success] = service.success? ? 'Application Shortlisted.' : flash[:error] = 'Something went wrong'

    redirect_back(fallback_location: job_applicants_path(@job))
  end

  def reject
    service = Service::Applicant::Reject.call(@job, params)
    flash[:success] = service.success? ? 'Application Rejected.' : flash[:error] = 'Something went wrong'

    redirect_back(fallback_location: job_applicants_path(@job))
  end

  def download_resume
    cover_letter = Query::Applicant::CoverLetter::Find.call(job: @job, params:)
    return redirect_back_or_to job_applicants_path(@job), error: 'Unable to find Resume.' if cover_letter.blank?

    send_data cover_letter.download, filename: cover_letter.filename.to_s
  end

  def download_cover_letter
    cover_letter  = Query::Applicant::CoverLetter::Find.call(job: @job, params:)
    error_message =  'Unable to find Cover Letter'
    return redirect_back(fallback_location: job_applicant_path(@job, params[:id])), error: error_message if cover_letter.blank?

    send_data cover_letter.download, filename: cover_letter.filename.to_s
  end

  private

  def set_job
    @job = Job.find(params[:job_id])
  end

  def authorize_user
    authorize @job, policy_class: ApplicantPolicy
  end
end
