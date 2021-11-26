class ResumesController < ApplicationController
  layout 'dashboard', only: [:new]

  def new
    @user = User.includes(resumes_attachments: :blob).find(params[:user_id])
  end

  def create
    @user = User.find(params[:user_id])
    if @user.resumes.attach(params[:user][:resumes])
      flash[:success] = 'Resume Attached'
      redirect_to new_user_resume_path(@user)
    else
      flash[:error] = 'Resume did not Attach.'
      redirect_to new_user_resume_path(@user, error_messages: @user.error.full_messages)
    end
  end

  def download
    @user = User.find(params[:user_id])
    resume = @user.resumes.find(params[:id])
    send_data resume.download, filename: resume.filename.to_s
  end

  def destroy
    @user = User.find(params[:user_id])
    resume = @user.resumes.find(params[:id])
    resume.purge
    flash[:success] ='Resume Deleted'
    redirect_to new_user_resume_path(@user)
  end
end