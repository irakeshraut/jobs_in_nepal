# frozen_string_literal: true

class AdminAreaPolicy < ApplicationPolicy
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

  def index?
    user_record == user && user.admin?
  end

  def expire_jobs?
    user_record == user && user.admin?
  end

  def delete_admin_expired_jobs?
    user_record == user && user.admin?
  end

  def delete_all_expired_jobs?
    user_record == user && user.admin?
  end
end
