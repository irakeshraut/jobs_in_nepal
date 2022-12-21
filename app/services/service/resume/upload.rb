# frozen_string_literal: true

module Service
  module Resume
    class Upload
      include BaseService

      def initialize(user, applicant, params)
        @user      = user
        @applicant = applicant
        @params    = params
      end

      def call
        attach_existing_resume and return if params[:resume].present?

        upload_new_resume if params[:resume_file].present?
      end

      private

      attr_reader :user, :applicant, :params

      def attach_existing_resume
        applicant.resume_name = params[:resume]
      end

      def upload_new_resume
        if user.resumes.attach(params[:resume_file])
          set_resume_name
          user.delete_resumes_greater_than_10
        else
          add_error_messages
        end
      end

      def set_resume_name
        resume = user.resumes.order(created_at: :desc).first
        applicant.resume_name = "#{resume.filename} - #{resume.created_at.strftime('%d/%m/%Y')}"
      end

      def add_error_messages
        user.errors.full_messages.each { |error| errors.add(:base, error) }
      end
    end
  end
end
