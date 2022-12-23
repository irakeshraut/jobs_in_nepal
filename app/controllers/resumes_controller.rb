# frozen_string_literal: true

class ResumesController < ApplicationController
  layout 'dashboard'

  before_action :set_user, except: :create
  before_action :set_user_with_resumes, only: :create
  before_action :authorize_user

  def new
    @resumes = @user.resumes_with_blob.to_a
  end

  def create
    if @user.resumes.attach(io: params[:user][:resume], filename: new_filename)
      flash[:success] = 'Resume Attached'
      Service::Resume::Old::Delete.call(@user)

      redirect_to new_user_resume_path(@user)
    else
      @resumes = @user.reload.resumes.to_a
      render :new
    end
  end

  def download
    resume = @user.resumes.find(params[:id])
    send_data resume.download, filename: resume.filename.to_s
  end

  def destroy
    service = Service::Resume::Delete.call(@user, params)

    if service.success?
      flash[:success] = 'Resume Deleted'
      redirect_to new_user_resume_path(@user)
    else
      @visible_resume = service.errors[:visible_resume].present?
      @resumes = @user.resumes_with_blob.to_a
      render :new
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_user_with_resumes
    @user = User.with_attached_resumes.find(params[:user_id])
  end

  def authorize_user
    authorize @user, policy_class: ResumePolicy
  end

  def new_filename
    original_filename = params[:user][:resume].original_filename
    "#{original_filename} - #{Time.zone.now.to_i}"
  end
end
