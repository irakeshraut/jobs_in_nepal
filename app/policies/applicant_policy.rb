# frozen_string_literal: true

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

  def index?
    user.employer? && job.user == user
  end

  def show?
    user.employer? && job.user == user
  end

  def new?
    user.job_seeker? && !job.users.include?(user)
  end

  def create?
    user.job_seeker? && !job.users.include?(user)
  end

  def shortlist?
    user.employer? && job.user == user
  end

  def reject?
    user.employer? && job.user == user
  end

  def download_resume?
    user.employer? && job.user == user
  end

  def download_cover_letter?
    user.employer? && job.user == user
  end
end
