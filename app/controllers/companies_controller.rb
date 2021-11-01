class CompaniesController < ApplicationController
  def create
    @company = Company.new(company_params)
    if @company.valid? && @company.save
      redirect_to root_path
    else
      redirect_to new_user_path(tab: 'employer', error_messages: @company.errors.full_messages)
    end
  end

  private

  def company_params
    params.require(:company).permit(:name, :phone, users_attributes: [:first_name, :last_name, :email, :password,
                                                                      :role, :password_confirmation, :company_id])
  end
end
