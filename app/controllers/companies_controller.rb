class CompaniesController < ApplicationController
  skip_before_action :require_login, only: [:create]
  layout 'dashboard', only: [:edit, :update]

  def create
    @company = Company.new(company_params)
    @company.users.first.role = 'employer'
    @user = User.new(@company.users.first.attributes)
    if @company.valid? && @company.save
      redirect_to login_path
    else
      @tab = 'employer'
      render 'users/new'
    end
  end

  def edit
    @company = Company.find(params[:id])
    authorize @company
  end

  def update
    @company = Company.find(params[:id])
    authorize @company
    if @company.update_attributes(company_params)
      flash[:success] = 'Company Details Successfully Updated.'
      redirect_to edit_company_path(@company)
    else
      render :edit
    end
  end

  private

  def company_params
    params.require(:company).permit(:name, :phone, :url, :description, :logo, users_attributes: 
                                    [:first_name, :last_name, :email, :password, 
                                     :password_confirmation, :company_id])
  end
end
