# frozen_string_literal: true

module Service
  module Applicant
    class Reject
      include BaseService

      def initialize(job, params)
        @job    = job
        @params = params
      end

      def call
        find_applicant
        reject_applicant ? send_rejection_email : errors.add(:message, 'Something went wrong')
      end

      private

      attr_reader :job, :params, :applicant

      def find_applicant
        @applicant = job.applicants.find_by(user_id: params[:id])
      end

      def reject_applicant
        applicant.update(status: 'Rejected')
      end

      def send_rejection_email
        return if applicant.rejected_email_sent?

        ApplicantMailer.application_rejected(job, applicant).deliver_later
        applicant.update(rejected_email_sent: true)
      end
    end
  end
end
