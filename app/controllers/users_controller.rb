# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new create activate]
  layout 'dashboard', only: %i[edit update all_posted_jobs edit_password update_password applied_jobs]

  before_action :set_user, only: %i[edit_password update_password]
  before_action :authorize_user, only: %i[edit_password update_password]

  def new
    @user = User.new
    @company = Company.new
    @tab = params[:tab] if params[:tab]
    redirect_to new_user_path(tab: 'job_seeker') unless @tab
  end

  def create
    @user = User.new(user_params)
    @user.role = 'job_seeker'
    @company = Company.new
    if @user.valid? && @user.save
      flash[:success] = 'Account Created. Please check your email to Activate your account.'
      redirect_to login_path
    else
      @tab = 'job_seeker'
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = User.includes(cover_letters_attachments: :blob, resumes_attachments: :blob).find(params[:id])
    authorize @user
    if @user.update(user_params)
      case params[:redirect_to]
      when 'edit_work_experience_path'
        flash[:success] = 'Work Experience Successfully Updated.'
        redirect_to new_user_work_experience_path(@user)
      when 'edit_education_path'
        flash[:success] = 'Education Successfully Updated.'
        redirect_to new_user_education_path(@user)
      else
        flash[:success] = 'User Profile Successfully Updated.'
        redirect_to edit_user_path(@user)
      end
    elsif params[:redirect_to] == 'edit_work_experience_path'
      @highlight_work_experience_navigation = true
      render 'work_experiences/new'
    elsif params[:redirect_to] == 'edit_education_path'
      @highlight_education_navigation = true
      render 'educations/new'
    else
      @highlight_edit_profile_navigation = true
      render :edit
    end
  end

  def edit_password
    @user = User.find(params[:id])
    authorize @user
  end

  def update_password
    old_current_user = current_user # need to set current_user before using login otherwise current_user will be nil when login fail.

    @user = login(old_current_user.email, params[:current_password])
    authorize @user if @user

    if @user
      if @user.update(password_params)
        flash[:success] = 'Password Successfully Updated.'
        redirect_to user_dashboards_path(@user)
      else
        render :edit_password
      end
    else
      @current_user = old_current_user
      @user = @current_user
      @invalid_current_password = true
      render :edit_password
    end
  end

  def all_posted_jobs
    @user = User.find(params[:id])
    authorize @user

    @jobs = Query::Employer::Job::Search.call(@user, params)
  end

  def applied_jobs
    @user = User.find(params[:id])
    authorize @user
    @applied_jobs = @user.applied_jobs.order(created_at: :desc).includes(user: { company: [logo_attachment: :blob] }).paginate(
      page: params[:page], per_page: 30
    )
  end

  def activate
    if (@user = User.load_from_activation_token(params[:id]))
      @user.activate!
      flash[:success] = 'User successfully activated'
      redirect_to(login_path)
    else
      not_authenticated
    end
  end

  def delete_avatar
    @user = User.find(params[:id])
    authorize @user
    @user.avatar.purge
    flash[:success] = 'Avatar Deleted.'
    redirect_to edit_user_path(@user)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user
    authorize @user
  end

  def password_params
    params.permit(:password, :password_confirmation)
  end

  def edit_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_no)
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :phone_no, :avatar, :password, :password_confirmation, :city, :skills,
      :profile_visible, :visible_resume_name, work_experiences_attributes:, educations_attributes:
    )
  end

  def work_experiences_attributes
    %i[id job_title company_name _destroy start_month start_year finish_month finish_year still_in_role description]
  end

  def educations_attributes
    %i[id institution_name course_name course_completed finished_year
       _destroy expected_finish_month expected_finish_year course_highlights]
  end
end
