# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  attr_reader :user, :record

  def initialize(user, record)
    @user   = user
    @record = record
  end

  def index?
    user == record
  end

  def jobs_posted_by_employers_today?
    user == record && user.admin?
  end

  def all_jobs_posted_by_admin_and_employers?
    user == record && user.admin?
  end
end
