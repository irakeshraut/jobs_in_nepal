# frozen_string_literal: true

class AdminAreaPolicy < ApplicationPolicy
  attr_reader :user

  def index?
    user.admin?
  end

  def expire_jobs?
    index?
  end

  def delete_admin_expired_jobs?
    index?
  end

  def delete_all_expired_jobs?
    index?
  end
end
