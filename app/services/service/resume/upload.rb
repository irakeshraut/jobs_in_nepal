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
        attach_existing_resume || upload_new_resume
      end

      private

      attr_reader :user, :applicant, :params

      def attach_existing_resume
        applicant.resume_name = params[:resume] if params[:resume].present?
      end

      def upload_new_resume
        return if params[:resume_file].blank?

        if user.resumes.attach(io: params[:resume_file], filename:)
          set_resume_name
          delete_old_resumes
        else
          add_error_message
        end
      end

      def filename
        @filename ||= "#{original_filename} - #{Time.zone.now.to_i}"
      end

      def original_filename
        params[:resume_file].original_filename
      end

      def set_resume_name
        applicant.resume_name = filename
      end

      def delete_old_resumes
        Service::Resume::Old::Delete.call(user)
      end

      def add_error_message
        user.errors.full_messages.each { |error| errors.add(:base, error) }
      end
    end
  end
end
