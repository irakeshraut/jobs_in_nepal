# frozen_string_literal: true

class CoverLettersController < ApplicationController
  layout 'dashboard', only: %i[new create]

  def new
    @user = User.includes(cover_letters_attachments: :blob).find(params[:user_id])
    authorize @user, policy_class: CoverLetterPolicy
    @cover_letters = @user.split_cover_letters_in_group_of_2
  end

  def create
    @user = User.includes(cover_letters_attachments: :blob).find(params[:user_id])
    authorize @user, policy_class: CoverLetterPolicy
    if @user.cover_letters.attach(params[:user][:cover_letter])
      flash[:success] = 'Cover Letter Attached'
      @user.delete_cover_letters_greater_than_10
      redirect_to new_user_cover_letter_path(@user)
    else
      # when cover letter attach fails, cover letter is still attached with id nil
      @user.delete_cover_letters_with_id_nil
      @cover_letters = @user.split_cover_letters_in_group_of_2
      render :new
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
    flash[:success] = 'Cover Letter Deleted'
    redirect_to new_user_cover_letter_path(@user)
  end
end
