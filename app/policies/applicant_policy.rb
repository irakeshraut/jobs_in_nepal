class ApplicantPolicy < ApplicationPolicy
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
    user.job_seeker?
  end

  def create?
    user.job_seeker?
  end
end
