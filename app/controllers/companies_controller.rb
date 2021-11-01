class CompaniesController < ApplicationController
  def create
    @company = Company.new(company_params)
    @company.users.first.role = 'employer'
    if @company.valid? && @company.save
      redirect_to root_path
    else
      redirect_to new_user_path(tab: 'employer', error_messages: @company.errors.full_messages)
    end
  end

  private

  def company_params
    params.require(:company).permit(:name, :phone, users_attributes: [:first_name, :last_name, :email, :password,
                                                                      :password_confirmation, :company_id])
  end
end
