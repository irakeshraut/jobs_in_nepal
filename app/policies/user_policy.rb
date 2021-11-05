class UserPolicy < ApplicationPolicy
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

  def edit?
    user_record == user
  end
  
  def update?
    user_record == user
  end

  def update_password?
    user_record == user
  end
end
