class HomePagesController < ApplicationController
  skip_before_action :require_login, only: [:index]

  def index
    @jobs = Job.active.order(created_at: :desc).limit(48)
    created_by_employer = @jobs.created_by_employers 
    if created_by_employer.present?
      @jobs = @jobs.includes(user: { company: [logo_attachment: :blob] })
    end
    @jobs
  end
end
