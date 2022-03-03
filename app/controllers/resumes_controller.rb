class ResumesController < ApplicationController
  layout 'dashboard', only: [:new, :create]

  def new
    @user = User.includes(resumes_attachments: :blob).find(params[:user_id])
    authorize @user, policy_class: ResumePolicy
    @resumes = @user.split_resumes_in_group_of_2
  end

  def create
    @user = User.includes(resumes_attachments: :blob).find(params[:user_id])
    authorize @user, policy_class: ResumePolicy
    if @user.resumes.attach(params[:user][:resume])
      flash[:success] = 'Resume Attached'
      @user.delete_resumes_greater_than_10
      redirect_to new_user_resume_path(@user)
    else
      # when resume attach fails, resume is still attached with id nil
      @user.delete_resumes_with_id_nil
      @resumes = @user.split_resumes_in_group_of_2
      render :new
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
