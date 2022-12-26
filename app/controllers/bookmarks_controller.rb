# frozen_string_literal: true

class BookmarksController < ApplicationController
  layout 'dashboard', only: [:index]

  before_action :set_user
  before_action :authorize_user, except: :destroy

  def index
    @bookmarks = @user.bookmarks.order(created_at: :desc).paginate(page: params[:page], per_page: 30)
  end

  def create
    job_id = params[:job_id]
    bookmark = @user.bookmarks.new(job_id:)
    bookmark.save ? flash[:success] = 'Job Saved' : flash[:error] = 'Unable to Save Job.'

    redirect_to job_path(job_id)
  end

  def destroy
    bookmark = Bookmark.find(params[:id])
    authorize bookmark, policy_class: BookmarkPolicy

    bookmark.destroy
    flash[:success] = 'Saved Job Deleted.'

    redirect_to user_bookmarks_path(@user)
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def authorize_user
    authorize @user, policy_class: BookmarkPolicy
  end
end
