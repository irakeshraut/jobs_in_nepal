# frozen_string_literal: true

class HomePagesController < ApplicationController
  skip_before_action :require_login, only: [:index]

  def index
    @jobs = Job.active.order(job_type: :asc, created_at: :desc).limit(48)
    created_by_employer = @jobs.created_by_employers
    @jobs = @jobs.includes(user: { company: [logo_attachment: :blob] }) if created_by_employer.present?
  end
end
