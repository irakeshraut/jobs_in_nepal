class EducationsController < ApplicationController
  layout 'dashboard', only: [:new]

  def new
    @user = User.find(params[:user_id])
    authorize @user, policy_class: EducationPolicy
    @error_messages = params[:error_messages] if params[:error_messages]
  end
end
