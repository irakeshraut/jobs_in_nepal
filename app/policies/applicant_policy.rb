# frozen_string_literal: true

class ApplicantPolicy < ApplicationPolicy
  attr_reader :user, :job

  def initialize(user, job)
    @user = user
    @job  = job
  end

  def index?
    user.employer? && job.user == user
  end

  def show?
    index?
  end

  def new?
    user.job_seeker? && !job.users.include?(user)
  end

  def create?
    new?
  end

  def shortlist?
    user.employer? && job.user == user
  end

  def reject?
    shortlist?
  end

  def download_resume?
    shortlist?
  end

  def download_cover_letter?
    shortlist?
  end
end
