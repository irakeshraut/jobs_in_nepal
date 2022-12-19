# frozen_string_literal: true

class WorkExperiencesController < ApplicationController
  layout 'dashboard', only: [:new]

  def new
    @user = User.with_rich_text_description.find(params[:user_id])
    authorize @user, policy_class: WorkExperiencePolicy
  end
end
