# frozen_string_literal: true

class EducationsController < ApplicationController
  layout 'dashboard', only: [:new]

  def new
    @user = User.with_education.find(params[:user_id])
    authorize @user, policy_class: EducationPolicy
  end
end
