# frozen_string_literal: true

class StaticPagesController < ApplicationController
  skip_before_action :require_login

  def terms_and_conditions; end

  def privacy_policy; end
end
