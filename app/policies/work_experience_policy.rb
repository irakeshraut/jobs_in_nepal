class WorkExperiencePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  attr_reader :user, :work_experience

  def initialize(user, work_experience)
    @user = user
    @work_experience = work_experience
  end

  def new?
    user.job_seeker?
  end
end
