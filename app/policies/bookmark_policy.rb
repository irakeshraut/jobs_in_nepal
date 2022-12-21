# frozen_string_literal: true

class BookmarkPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    # TODO: this may be wrong, test it.
    user == record
  end

  def create?
    record.user == user && !user.bookmarks.where(job_id: record.job_id).present?
  end

  def destroy?
    record.user == user
  end
end
