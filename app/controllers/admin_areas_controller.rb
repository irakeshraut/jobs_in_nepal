class AdminAreasController < ApplicationController
  layout 'dashboard'

  def index
    user = current_user
    authorize user, policy_class: AdminAreaPolicy

    @old_jobs = Job.old_jobs
  end

  def expire_jobs
    user = current_user
    authorize user, policy_class: AdminAreaPolicy

    Job.old_jobs.each do |old_job|
      old_job.status = 'Expired'
      old_job.save
    end

    redirect_to admin_areas_path
  end

  def delete_admin_expired_jobs
    user = current_user
    authorize user, policy_class: AdminAreaPolicy

    Job.expired.created_by_admin.destroy_all
    redirect_to admin_areas_path
  end

  def delete_all_expired_jobs
    user = current_user
    authorize user, policy_class: AdminAreaPolicy

    Job.expired.destroy_all
    redirect_to admin_areas_path
  end
end
