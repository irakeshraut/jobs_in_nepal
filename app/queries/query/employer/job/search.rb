# frozen_string_literal: true

module Query
  module Employer
    module Job
      class Search
        include BaseQuery

        def initialize(user, params)
          @user   = user
          @params = params
        end

        def call
          find_all_jobs
          filter_by_title
          filter_by_status
          pagination
        end

        private

        attr_reader :user, :params

        # TODO: This have N + 1 query, includes is not working and bullet gem is saying not to use include
        def find_all_jobs
          @jobs = user.jobs.order(created_at: :desc)
        end

        def filter_by_title
          @jobs = @jobs.filter_by_title(params[:title]) if params[:title].present?
        end

        def filter_by_status
          @jobs = @jobs.filter_by_status(params[:status]) if params[:status].present?
        end

        def pagination
          @jobs = @jobs.paginate(page: params[:page], per_page: 30)
        end
      end
    end
  end
end
