class CoverLettersController < ApplicationController
  layout 'dashboard', only: [:new, :create]

  def new
    @user = User.includes(cover_letters_attachments: :blob).find(params[:user_id])
    authorize @user, policy_class: CoverLetterPolicy
    if @user.cover_letters.size > 0 
      @cover_letters = @user.cover_letters.order(created_at: :desc).in_groups_of((@user.cover_letters.size/2.0).round, false)
    else
      @cover_letters = [[],[]]
    end
  end

  def create
    @user = User.includes(cover_letters_attachments: :blob).find(params[:user_id])
    authorize @user, policy_class: CoverLetterPolicy
    if @user.cover_letters.count >= 10
      @user.cover_letters.order(:created_at).first.purge
    end
    if @user.cover_letters.attach(params[:user][:cover_letter])
      flash[:success] = 'Cover Letter Attached'
      redirect_to new_user_cover_letter_path(@user)
    else
      # when attachment fails, record is still attached to user.cover_letters with id of nil. @user.cover_letters.last.destroy 
      # is not reliable so I am looping through all cover_letters to delete the cover_letters with id of nil. 
      # All below code are just setup for render :new
      @user.cover_letters.each do |cover_letter|
        cover_letter.destroy if cover_letter.id.nil?
      end
      if @user.cover_letters.size > 0 
        @cover_letters = @user.cover_letters.order(created_at: :desc).in_groups_of((@user.cover_letters.size/2.0).round, false)
      else
        @cover_letters = [[],[]]
      end

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
    flash[:success] ='Cover Letter Deleted'
    redirect_to new_user_cover_letter_path(@user)
  end
end
