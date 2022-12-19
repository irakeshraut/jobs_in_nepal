# frozen_string_literal: true

class CoverLetterPolicy < ApplicationPolicy
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

  def new?
    user.job_seeker? && user_record == user
  end

  def create?
    user.job_seeker? && user_record == user
  end

  def download?
    user.job_seeker? && user_record == user
  end

  def destroy?
    user.job_seeker? && user_record == user
  end
end
