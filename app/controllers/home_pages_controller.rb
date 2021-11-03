class HomePagesController < ApplicationController
  skip_before_action :require_login, only: [:index]
  
  def index
    @jobs = Job.all.reverse
  end
end
