# frozen_string_literal: true

module Service
  module Applicant
    class Create
      include BaseService

      def initialize(job, user, params)
        @job       = job
        @user      = user
        @params    = params
        @applicant = job.applicants.build
      end

      def call
        upload_resume
        upload_cover_letter
        send_application_submitted_email if save_applicant
      end

      private

      attr_reader :job, :params, :user, :applicant, :resume_service, :cover_letter_service

      def upload_resume
        @resume_service = Service::Resume::Upload.call(user, applicant, params)
      end

      def upload_cover_letter
        @cover_letter_service = Service::CoverLetter::Upload.call(user, applicant, params)
      end

      def save_applicant
        applicant.user_id = @user.id
        add_error_messages and return if error_present?

        applicant.save
      end

      def send_application_submitted_email
        ApplicantMailer.application_submitted(user, job, applicant).deliver_later
        EmployerMailer.application_submitted(job.user, job, user).deliver_later
      end

      def error_present?
        resume_service.errors.present? || cover_letter_service.errors.present? || applicant.invalid?
      end

      def add_error_messages
        objects = [applicant, resume_service, cover_letter_service]
        objects.flat_map(&:errors).full_messages.each { |message| errors.add(:base, message) }
      end
    end
  end
end
