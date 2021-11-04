class JobPolicy < ApplicationPolicy
  attr_reader :user, :post

  def initialize(user, post)
    @user = user
    @post = post
  end

  def new?
    user.admin? || user.employer?
  end

  def create?
    user.admin? || user.employer?
  end
end
