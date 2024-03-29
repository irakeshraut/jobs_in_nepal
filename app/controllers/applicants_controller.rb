# frozen_string_literal: true

class ApplicantsController < ApplicationController
  layout 'dashboard', except: %i[new create]

  before_action :set_job # TODO: this need to set nicely and other variables applicants need to be setup
  before_action :authorize_user
  before_action :set_user_with_resume_and_cover_letter, only: :create
  before_action :set_user,      only: %i[download_resume download_cover_letter]
  before_action :set_applicant, only: %i[download_resume download_cover_letter]

  def index
    @users = Query::Applicant::Search.call(@job, params)
  end

  # TODO: check pundit for this, before_action :set_job need to ignore this or change applicant_user to user
  def show
    @user      = @job.users.with_education_and_work_experience.find(params[:id])
    applicant  = @job.applicants.find_by(user_id: @user.id)
    @presenter = Presenter::Applicant::Show.new(@user, applicant)

    Service::Applicant::Viewed.call(@job, @user, applicant)
  end

  def new
    @user      = User.with_education_and_work_experience.find(current_user.id)
    @presenter = Presenter::Applicant::New.new(@user, view_context)
    redirect_link = @job.redirect_link

    redirect_to redirect_link if redirect_link.present?
  end

  def create
    @service = Service::Applicant::Create.call(@job, @user, params)

    if @service.success?
      flash[:success] = 'Application Submitted.'
      redirect_to root_path
    else
      @presenter = Presenter::Applicant::New.new(@user.reload, view_context)
      render :new
    end
  end

  def shortlist
    service = Service::Applicant::Shortlist.call(@job, params)
    flash[:success] = service.success? ? 'Application Shortlisted.' : flash[:error] = 'Something went wrong'

    redirect_back(fallback_location: job_applicants_path(@job))
  end

  def reject
    service = Service::Applicant::Reject.call(@job, params)
    flash[:success] = service.success? ? 'Application Rejected.' : flash[:error] = 'Something went wrong'

    redirect_back(fallback_location: job_applicants_path(@job))
  end

  # TODO: need to fix pundit for this whole file, browser makes 2 request to download file, very weird
  def download_resume
    resume = Query::Applicant::Resume::Find.call(@user, @applicant)
    return redirect_back(fallback_location: job_applicants_path(@job)), error: 'Unable to find Resume.' if resume.blank?

    send_data resume.download, filename: resume.filename.to_s.split(' - ').first
  end

  def download_cover_letter
    cover_letter  = Query::Applicant::CoverLetter::Find.call(@user, @applicant)
    error_message = 'Unable to find Cover Letter'

    if cover_letter.blank?
      return redirect_back(fallback_location: job_applicant_path(@job, params[:id])), error: error_message
    end

    send_data cover_letter.download, filename: cover_letter.filename.to_s.split(' - ').first
  end

  private

  def set_job
    @job = Job.find(params[:job_id])
  end

  def set_applicant
    @applicant = @job.applicants.find_by(user_id: @user.id)
  end

  def authorize_user
    authorize @job, policy_class: ApplicantPolicy
  end

  def set_user
    @user = User.find(params[:id])
  end

  def set_user_with_resume_and_cover_letter
    id = params[:user_id]
    @user = if params[:resume_file] || params[:cover_letter_file]
              User.with_resume_and_cover_letter.find(id)
            else
              User.find(id)
            end
  end
end
