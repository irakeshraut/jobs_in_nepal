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
    user.admin? || user.employer?
  end

  def edit?
    (user.admin? || user.employer?) && job.user == user
  end

  def update?
    (user.admin? || user.employer?) && job.user == user
  end

  def destroy?
    job.user == user
  end

  def close_job?
    user.employer? && job.user == user && !job.expired?
  end

  def reopen_job?
    user.employer? && job.user == user && !job.expired?
  end
end
