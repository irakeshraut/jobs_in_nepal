# frozen_string_literal: true

class AdminAreasController < ApplicationController
  layout 'dashboard'

  before_action :set_user
  before_action :authorize_user

  def index
    @old_jobs = Job.old_jobs
  end

  def expire_jobs
    Job.old_jobs.update_all(status: 'Expired')

    redirect_to admin_areas_path
  end

  def delete_admin_expired_jobs
    Job.created_by_admin.expired.destroy_all

    redirect_to admin_areas_path
  end

  def delete_all_expired_jobs
    Job.expired.destroy_all

    redirect_to admin_areas_path
  end

  private

  def set_user
    @user = current_user
  end

  def authorize_user
    authorize @user, policy_class: AdminAreaPolicy
  end
end
