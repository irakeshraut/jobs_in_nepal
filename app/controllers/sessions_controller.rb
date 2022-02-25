class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
  end

  def create
    @user = login(params[:email], params[:password])
    if @user
      redirect_back_or_to(root_path)
    else
      @user = User.find_by(email: params[:email])
      if @user && @user.activation_state == 'pending'
        @account_pending = true
        render :new and return
      end
      flash[:error] = 'Login Failed: Invalid Email or Password'
      redirect_to login_path
    end
  end

  def destroy
    logout
    redirect_to(login_path)
  end
end
