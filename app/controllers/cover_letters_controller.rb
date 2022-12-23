# frozen_string_literal: true

class CoverLettersController < ApplicationController
  layout 'dashboard', only: %i[new create]

  before_action :set_user_with_cover_letters, only: %i[new create]
  before_action :set_user, only: %i[download destroy]
  before_action :authorize_user

  def new
    @cover_letters = @user.cover_letters_with_blob.to_a
  end

  def create
    if @user.cover_letters.attach(io: params[:user][:cover_letter], filename: new_filename)
      flash[:success] = 'Cover Letter Attached'
      Service::CoverLetter::Old::Delete.call(@user)
      redirect_to new_user_cover_letter_path(@user)
    else
      @cover_letters = @user.reload.cover_letters_with_blob.to_a
      render :new
    end
  end

  def download
    cover_letter = @user.cover_letters.find(params[:id])
    send_data cover_letter.download, filename: cover_letter.filename.to_s
  end

  def destroy
    cover_letter = @user.cover_letters.find(params[:id])
    cover_letter.purge
    flash[:success] = 'Cover Letter Deleted'

    redirect_to new_user_cover_letter_path(@user)
  end

  private

  def set_user_with_cover_letters
    @user = User.includes(cover_letters_attachments: :blob).find(params[:user_id])
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def authorize_user
    authorize @user, policy_class: CoverLetterPolicy
  end

  def new_filename
    original_filename = params[:user][:cover_letter].original_filename
    "#{original_filename} - #{Time.zone.now.to_i}"
  end
end
