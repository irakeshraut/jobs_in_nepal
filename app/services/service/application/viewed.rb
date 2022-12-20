# frozen_string_literal: true

module Service
  module Application
    class Viewed
      include BaseService

      def initialize(job, applicant_user, applicant)
        @job            = job
        @applicant_user = applicant_user
        @applicant      = applicant
      end

      def call
        return if applicant.viewed_by_employer?

        mark_applicant_as_viewed
        send_applicant_viewed_email
      end

      private

      attr_reader :job, :applicant_user, :applicant

      def mark_applicant_as_viewed
        applicant.update!(viewed_by_employer: true)
      end

      def send_applicant_viewed_email
        ApplicantMailer.application_viewed(applicant_user, job, applicant).deliver_later
      end
    end
  end
end
