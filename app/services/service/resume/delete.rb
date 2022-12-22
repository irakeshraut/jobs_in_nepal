# frozen_string_literal: true

module Service
  module Resume
    class Delete
      include BaseService

      def initialize(user, params)
        @user   = user
        @params = params
      end

      # TODO: if resume is attached to job which are active, then show error message to user
      # if user decides to delete resume attached to job then shall we delete applicant for job ?
      def call
        find_resume
        delete_resume
      end

      private

      attr_reader :user, :params, :resume

      def find_resume
        @resume = @user.resumes.find(params[:id])
      end

      def delete_resume
        add_error_message and return if visible_resume?

        resume.purge
      end

      def visible_resume?
        user.profile_visible && resume.filename == user.visible_resume_name
      end

      def add_error_message
        errors.add(:visible_resume, "Can't delete visible resume")
      end
    end
  end
end
