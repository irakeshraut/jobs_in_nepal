# frozen_string_literal: true

class CoverLettersController < ApplicationController
  layout 'dashboard', only: %i[new create]

  before_action :set_user, only: %i[new create]
  before_action :authorize_user, only: %i[new create]

  def new
    @cover_letters = @user.split_cover_letters_in_group_of_2
  end

  def create
    if @user.cover_letters.attach(params[:user][:cover_letter])
      flash[:success] = 'Cover Letter Attached'
      @user.delete_cover_letters_greater_than_10
      redirect_to new_user_cover_letter_path(@user)
    else
      # when cover letter attach fails, cover letter is still attached with id nil
      # TODO: delete below line at reload user once N + 1 query is fixed
      @user.cover_letters.each { |cover_letter| cover_letter.destroy if cover_letter.id.nil? }
      @cover_letters = @user.split_cover_letters_in_group_of_2
      render :new
    end
  end

  def download
    # TODO: I am suprised this don't have N + 1 query issues. Test it.
    @user = User.find(params[:user_id])
    authorize @user, policy_class: CoverLetterPolicy
    cover_letter = @user.cover_letters.find(params[:id])
    send_data cover_letter.download, filename: cover_letter.filename.to_s
  end

  def destroy
    # TODO: this have N + 1 query problem, fix it
    @user = User.find(params[:user_id])
    authorize @user, policy_class: CoverLetterPolicy
    cover_letter = @user.cover_letters.find(params[:id])
    cover_letter.purge
    flash[:success] = 'Cover Letter Deleted'
    redirect_to new_user_cover_letter_path(@user)
  end

  private

  def set_user
    @user = User.includes(cover_letters_attachments: :blob).find(params[:user_id])
  end

  def authorize_user
    authorize @user, policy_class: CoverLetterPolicy
  end
end
