# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  attr_reader :user, :user_record

  def initialize(user, user_record)
    @user = user
    @user_record = user_record
  end

  def edit?
    user_record == user
  end

  def update?
    edit?
  end

  def edit_password?
    edit?
  end

  def update_password?
    edit?
  end

  def all_posted_jobs?
    edit?
  end

  def applied_jobs?
    user.job_seeker? && user_record == user
  end

  def delete_avatar?
    edit?
  end
end
