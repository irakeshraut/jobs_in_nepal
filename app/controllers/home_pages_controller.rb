class HomePagesController < ApplicationController
  skip_before_action :require_login, only: [:index]
  
  def index
    @jobs = Job.active.limit(48).reverse
  end
end
