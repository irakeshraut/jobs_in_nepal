# frozen_string_literal: true

module Query
  module Applicant
    class Search
      include BaseQuery

      def initialize(job, params)
        @job    = job
        @params = params
      end

      def call
        find_applicants
        filter_by_name
        filter_by_status
        pagination
      end

      private

      attr_reader :params

      def find_applicants
        @records = @job.users.includes([avatar_attachment: :blob])
      end

      def filter_by_name
        name = params[:name]
        @records = @records.filter_by_name(name) if name.present?
      end

      def filter_by_status
        status = params[:status]
        @records = @records.filter_by_status(status) if status.present?
      end

      def pagination
        @records.paginate(page: params[:page], per_page: 30)
      end
    end
  end
end
