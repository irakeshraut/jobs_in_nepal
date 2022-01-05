class BookmarksController < ApplicationController
  layout 'dashboard', only: [:index]

  def index
    @user = User.find(params[:user_id])
    authorize @user, policy_class: BookmarkPolicy
    @bookmarks = @user.bookmarks
  end

  def create
    user = User.find(params[:user_id])
    job = Job.find(params[:job_id])
    bookmark = user.bookmarks.new(job_id: params[:job_id])
    authorize bookmark, policy_class: BookmarkPolicy
    if bookmark.valid? && bookmark.save
      flash[:success] = 'Job Saved'
    else
      flash[:error] = 'Unable to Save Job.'
    end

    redirect_to job
  end

  def destroy
    user = User.find(params[:user_id])
    bookmark = Bookmark.find(params[:id])
    authorize bookmark, policy_class: BookmarkPolicy
    bookmark.destroy
    flash[:success] = 'Saved Job Deleted.'
    redirect_to user_bookmarks_path(user)
  end
end
