# frozen_string_literal: true

class JobPolicy < ApplicationPolicy
  attr_reader :user, :job

  def initialize(user, job)
    @user = user
    @job = job
  end

  def new?
    user.admin? || user.employer?
  end

  def create?
    new?
  end

  def edit?
    (user.admin? || user.employer?) && job.user == user
  end

  def update?
    edit?
  end

  def destroy?
    job.user == user
  end

  def close_job?
    (user.admin? || user.employer?) && job.user == user && !job.expired?
  end

  def reopen_job?
    close_job?
  end

  def closed_by_admin?
    user.admin? && !job.expired?
  end

  def reopened_by_admin?
    closed_by_admin?
  end
end
