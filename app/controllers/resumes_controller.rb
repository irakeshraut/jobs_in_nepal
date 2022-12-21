# frozen_string_literal: true

class ResumesController < ApplicationController
  layout 'dashboard'

  before_action :set_user, only: %i[new download]
  before_action :set_user_with_attachments, only: %i[create destroy]
  before_action :authorize_user

  def new
    @resumes = @user.resumes.includes(:blob).order(created_at: :desc).to_a
  end

  def create
    if @user.resumes.attach(params[:user][:resume])
      flash[:success] = 'Resume Attached'
      @user.delete_resumes_greater_than_10
      redirect_to new_user_resume_path(@user)
    else
      @resumes = @user.reload.resumes.order(created_at: :desc).to_a
      render :new
    end
  end

  def download
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

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_user_with_attachments
    # If I don't attach cover_letter for user then I get N + 1 in create action when create fails. Very strange
    # But destroy action will work without attached_cover_letters, I am just reusing same method of crete and destroy
    @user = User.with_attached_resumes.with_attached_cover_letters.find(params[:user_id])
  end

  def authorize_user
    authorize @user, policy_class: ResumePolicy
  end
end
