class ApplicantsController < ApplicationController
  def new
    @job = Job.find(params[:job_id])
    @user = current_user
    authorize @user, policy_class: ApplicantPolicy
    @error_messages = params[:error_messages] if params[:error_messages]
    if @job.redirect_link.present?
      redirect_to @job.redirect_link
    end
  end

  def create
    @job = Job.find(params[:job_id])
    @user = current_user
    authorize @user, policy_class: ApplicantPolicy
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
      redirect_to new_job_applicant_path(@job, error_messages: @user.errors.full_messages)
    end
  end
end
