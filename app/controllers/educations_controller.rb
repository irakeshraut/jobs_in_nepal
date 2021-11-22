class EducationsController < ApplicationController
  layout 'dashboard', only: [:new]

  def new
    @user = current_user
    @error_messages = params[:error_messages] if params[:error_messages]
  end
end
