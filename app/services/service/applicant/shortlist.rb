# frozen_string_literal: true

module Service
  module Applicant
    class Shortlist
      include BaseService

      def initialize(job, params)
        @job    = job
        @params = params
      end

      def call
        find_applicant
        errors.add(:message, 'Something went wrong') unless shortlist_applicant
      end

      private

      attr_reader :job, :params, :applicant

      def find_applicant
        @applicant = job.applicants.find_by(user_id: params[:id])
      end

      def shortlist_applicant
        applicant.update(status: 'Shortlisted')
      end
    end
  end
end
