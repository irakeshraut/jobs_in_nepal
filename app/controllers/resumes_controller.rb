class ResumesController < ApplicationController
  layout 'dashboard', only: [:new, :create]

  def new
    @user = User.includes(resumes_attachments: :blob).find(params[:user_id])
    authorize @user, policy_class: ResumePolicy
    if @user.resumes.size > 0 
      @resumes = @user.resumes.order(created_at: :desc).in_groups_of((@user.resumes.size/2.0).round, false)
    else
      @resumes = [[],[]]
    end
  end

  def create
    @user = User.includes(resumes_attachments: :blob).find(params[:user_id])
    authorize @user, policy_class: ResumePolicy
    if @user.resumes.count >= 10
      @user.resumes.order(:created_at).first.purge
    end
    if @user.resumes.attach(params[:user][:resume])
      flash[:success] = 'Resume Attached'
      redirect_to new_user_resume_path(@user)
    else
      # when attachment fails, record is still attached to user.resumes with id of nil. @user.resumes.last.destroy is not
      # reliable so I am looping through all resume to delete the resumes with id of nil. All below code are just setup for render :new
      @user.resumes.each do |resume|
        resume.destroy if resume.id.nil?
      end
      if @user.resumes.size > 0 
        @resumes = @user.resumes.order(created_at: :desc).in_groups_of((@user.resumes.size/2.0).round, false)
      else
        @resumes = [[],[]]
      end

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
