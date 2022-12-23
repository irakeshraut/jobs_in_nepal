# frozen_string_literal: true

module Query
  module Job
    class Search
      include BaseQuery

      def initialize(params)
        @params = params
      end

      def call
        find_active_jobs
        filter_by_title
        filter_by_category
        filter_by_location
        pagination
      end

      private

      attr_reader :jobs, :params

      def find_active_jobs
        @jobs = ::Job.active.order(job_type: :asc, created_at: :desc).limit(48) # may not need limit
        include_company_logo
      end

      def include_company_logo
        return unless jobs.created_by_employers.present?

        @jobs = jobs.includes(user: { company: [logo_attachment: :blob] })
      end

      def filter_by_title
        @jobs = jobs.filter_by_title(params[:title]) if params[:title].present?
      end

      def filter_by_category
        @jobs = jobs.filter_by_category(params[:category]) if params[:category].present?
      end

      def filter_by_location
        @jobs = jobs.filter_by_location(params[:location]) if params[:location].present?
      end

      def pagination
        @jobs = jobs.paginate(page: params[:page], per_page: 30)
      end
    end
  end
end
