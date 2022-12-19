# frozen_string_literal: true

class ResumesController < ApplicationController
  layout 'dashboard'

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
    @user = User.includes(resumes_attachments: :blob).find(params[:user_id])
    authorize @user, policy_class: ResumePolicy
    resume = @user.resumes.find(params[:id])
    if @user.profile_visible
      visible_resume_name, resume_created_date = @user.visible_resume_name.split(' - ')
      resume_filename = "#{resume.filename} - #{resume.created_at.strftime('%d/%m/%Y')}"
      if resume_filename == @user.visible_resume_name
        resume_count = @user.resumes.includes(:blob).references(:blob)
                            .where(active_storage_blobs: { filename: visible_resume_name,
                                                           created_at: Date.parse(resume_created_date).beginning_of_day..Date.parse(resume_created_date).end_of_day }).count
        if resume_count == 1
          @trying_to_delete_visible_resume = true
          @resumes = @user.split_resumes_in_group_of_2
          render :new and return
        end
      end
    end
    resume.purge
    flash[:success] = 'Resume Deleted'
    redirect_to new_user_resume_path(@user)
  end
end
