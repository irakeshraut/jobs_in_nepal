class CompaniesController < ApplicationController
  skip_before_action :require_login, only: [:create]
  layout 'dashboard', only: [:edit, :update]

  def create
    @company = Company.new(company_params)
    @company.users.first.role = 'employer'
    if @company.valid? && @company.save
      redirect_to login_path
    else
      redirect_to new_user_path(tab: 'employer', error_messages: @company.errors.full_messages)
    end
  end

  def edit
    @company = Company.find(params[:id])
    @error_messages = params[:error_messages] if params[:error_messages]
  end

  def update
    @company = Company.find(params[:id])
    if @company.update_attributes(edit_company_params)
      flash[:success] = 'Company Details Successfully Updated.'
      redirect_to edit_company_path(@company)
    else
      redirect_to edit_company_path(@company, error_messages: @company.errors.full_messages)
    end
  end

  private

  def edit_company_params
    params.require(:company).permit(:name, :phone)
  end

  def company_params
    params.require(:company).permit(:name, :phone, users_attributes: [:first_name, :last_name, :email, :password,
                                                                      :password_confirmation, :company_id])
  end
end
