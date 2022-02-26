class CompanyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  attr_reader :user, :company

  def initialize(user, company)
    @user = user
    @company = company
  end

  def edit?
    company.users.first == user
  end

  def update?
    company.users.first == user
  end

  def delete_logo?
    company.users.first == user
  end
end
