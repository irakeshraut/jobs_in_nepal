class ResumesController < ApplicationController
  layout 'dashboard', only: [:new]

  def new
    @user = User.includes(resumes_attachments: :blob).find(params[:user_id])
    authorize @user, policy_class: ResumePolicy
    @error_messages = params[:error_messages] if params[:error_messages]
  end

  def create
    @user = User.find(params[:user_id])
    authorize @user, policy_class: ResumePolicy
    if @user.resumes.attach(params[:user][:resume])
      flash[:success] = 'Resume Attached'
      redirect_to new_user_resume_path(@user)
    else
      redirect_to new_user_resume_path(@user, error_messages: @user.errors.full_messages)
    end
  end

  def download
    @user = User.find(params[:user_id])
    authorize @user, policy_class: ResumePolicy
    resume = @user.resumes.find(params[:id])
    send_data resume.download, filename: resume.filename.to_s
  end

  def destroy
    @user = User.find(params[:user_id])
    authorize @user, policy_class: ResumePolicy
    resume = @user.resumes.find(params[:id])
    resume.purge
    flash[:success] ='Resume Deleted'
    redirect_to new_user_resume_path(@user)
  end
end
