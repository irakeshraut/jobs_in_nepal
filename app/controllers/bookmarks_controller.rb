class BookmarksController < ApplicationController
  layout 'dashboard', only: [:index]

  def index
    @user = current_user
    @bookmarks = @user.bookmarks
  end

  def create
    job = Job.find(params[:job_id])
    bookmark = Bookmark.new(job_id: params[:job_id], user_id: current_user.id)
    if bookmark.save
      flash[:success] = 'Job Saved'
    else
      flash[:error] = 'Unable to Save Job.'
    end

    redirect_to job
  end

  def destroy
    bookmark = Bookmark.find(params[:id])
    bookmark.destroy
    flash[:success] = 'Saved Job Deleted.'
    redirect_to bookmarks_path
  end
end
