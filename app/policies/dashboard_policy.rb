# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
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

  def all_jobs_by_admin_and_employer?
    user == record && user.admin?
  end
end
