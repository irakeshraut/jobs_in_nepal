class CoverLettersController < ApplicationController
  layout 'dashboard', only: [:new]

  def new
    @user = User.includes(cover_letters_attachments: :blob).find(params[:user_id])
    if @user.cover_letters.size > 0 
      @cover_letters = @user.cover_letters.order(created_at: :desc).in_groups_of((@user.cover_letters.size/2.0).round, false)
    else
      @cover_letters = [[],[]]
    end
    authorize @user, policy_class: CoverLetterPolicy
    @error_messages = params[:error_messages] if params[:error_messages]
  end

  def create
    @user = User.find(params[:user_id])
    authorize @user, policy_class: CoverLetterPolicy
    if @user.cover_letters.count >= 10
      @user.cover_letters.order(:created_at).first.purge
    end
    if @user.cover_letters.attach(params[:user][:cover_letter])
      flash[:success] = 'Cover Letter Attached'
      redirect_to new_user_cover_letter_path(@user)
    else
      redirect_to new_user_cover_letter_path(@user, error_messages: @user.errors.full_messages)
    end
  end

  def download
    @user = User.find(params[:user_id])
    authorize @user, policy_class: CoverLetterPolicy
    cover_letter = @user.cover_letters.find(params[:id])
    send_data cover_letter.download, filename: cover_letter.filename.to_s
  end

  def destroy
    @user = User.find(params[:user_id])
    authorize @user, policy_class: CoverLetterPolicy
    cover_letter = @user.cover_letters.find(params[:id])
    cover_letter.purge
    flash[:success] ='Cover Letter Deleted'
    redirect_to new_user_cover_letter_path(@user)
  end
end
