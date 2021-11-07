class HomePagesController < ApplicationController
  skip_before_action :require_login, only: [:index]
  
  def index
    @jobs = Job.includes(user: { company: [logo_attachment: :blob]}).active.order(created_at: :desc).limit(48)
  end
end
