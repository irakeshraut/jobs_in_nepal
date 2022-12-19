# frozen_string_literal: true

class CompaniesController < ApplicationController
  skip_before_action :require_login, only: [:create]
  layout 'dashboard', only: %i[edit update]

  def create
    @company = Company.new(company_params)
    @company.users.first.role = 'employer'
    @user = User.new(@company.users.first.attributes)
    if @company.valid? && @company.save
      flash[:success] = 'Account Created. Please check your email to Activate your account.'
      redirect_to login_path
    else
      @tab = 'employer'
      render 'users/new'
    end
  end

  def edit
    @company = Company.includes([:rich_text_description]).find(params[:id])
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

  def delete_logo
    @company = Company.find(params[:id])
    authorize @company
    @company.logo.purge
    flash[:success] = 'Logo Deleted.'
    redirect_to edit_company_path(@company)
  end

  private

  def company_params
    params.require(:company).permit(:name, :phone, :url, :description, :logo, users_attributes:
                                    %i[first_name last_name email password
                                       password_confirmation company_id])
  end
end
