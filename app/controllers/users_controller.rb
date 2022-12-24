# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new create activate]
  layout 'dashboard', only: %i[edit update all_posted_jobs edit_password update_password applied_jobs]

  before_action :set_user, only: %i[edit edit_password update_password all_posted_jobs applied_jobs delete_avatar]
  before_action :authorize_user, only: %i[edit edit_password update_password all_posted_jobs applied_jobs delete_avatar]

  def new
    @user    = User.new
    @company = Company.new
    @tab     = params[:tab] if params[:tab]
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

  def edit; end

  def update
    @user = User.with_resume_and_cover_letter.find(params[:id])
    authorize @user

    if @user.update(user_params)
      flash[:success] = 'Update Successful'
      redirect_back(fallback_location: user_dashboards_path(@user))
    else
      @highlight_navigation = params[:render_template]
      render params[:render_template] || :edit
    end
  end

  # TODO: Create seperate PasswordController for this
  def edit_password; end

  # TODO: create separate controller called PasswordsController for this with Update method
  def update_password
    @service = Service::Password::Update.call(@user, password_params)
    flash[:success] = 'Password Successfully Updated.' if @service.success?

    @service.success? ? (redirect_to user_dashboards_path(@user)) : (render :edit_password)
  end

  def all_posted_jobs
    @jobs = Query::Employer::Job::Search.call(@user, params)
  end

  def applied_jobs
    @applied_jobs = @user.applied_jobs.with_company_logo.order(created_at: :desc)
                         .paginate(page: params[:page], per_page: 30)
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
    params.permit(:current_password, :password, :password_confirmation)
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
