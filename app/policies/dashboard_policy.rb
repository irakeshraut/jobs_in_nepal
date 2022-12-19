# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  attr_reader :user, :user_record

  def initialize(user, user_record)
    @user = user
    @user_record = user_record
  end

  def index?
    user_record == user
  end

  def jobs_posted_by_employers_today?
    user_record == user && user.admin?
  end

  def all_jobs_posted_by_admin_and_employers?
    user_record == user && user.admin?
  end
end
