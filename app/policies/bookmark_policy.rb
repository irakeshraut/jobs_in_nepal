# frozen_string_literal: true

class BookmarkPolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user == record
  end

  def create?
    index?
  end

  def destroy?
    user == record.user
  end
end
