class ApplicantPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  attr_reader :user, :job

  def initialize(user, job)
    @user = user
    @job = job
  end

  def new?
    user.job_seeker? && !job.users.include?(user)
  end

  def create?
    user.job_seeker? && !job.users.include?(user)
  end
end
