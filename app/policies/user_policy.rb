# frozen_string_literal: true

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

  def edit_password?
    user_record == user
  end

  def update_password?
    user_record == user
  end

  def all_posted_jobs?
    (user.employer? || user.admin?) && user_record == user
  end

  def applied_jobs?
    user.job_seeker? && user_record == user
  end

  def delete_avatar?
    user_record == user
  end
end
