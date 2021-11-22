class EducationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  attr_reader :user, :education

  def initialize(user, education)
    @user = user
    @work_experience = education
  end

  def new?
    user.job_seeker?
  end
end
