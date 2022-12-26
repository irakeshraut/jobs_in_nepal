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
        return if jobs.created_by_employers.blank?

        @jobs = jobs.includes(user: { company: [logo_attachment: :blob] })
      end

      def filter_by_title
        title = params[:title]
        @jobs = jobs.filter_by_title(title) if title.present?
      end

      def filter_by_category
        category = params[:category]
        @jobs    = jobs.filter_by_category(category) if category.present?
      end

      def filter_by_location
        location = params[:location]
        @jobs    = jobs.filter_by_location(location) if location.present?
      end

      def pagination
        @jobs = jobs.paginate(page: params[:page], per_page: 30)
      end
    end
  end
end
