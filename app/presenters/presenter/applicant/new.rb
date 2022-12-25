# frozen_string_literal: true

module Presenter
  module Applicant
    class New
      attr_reader :user, :view_context

      def initialize(user, view_context)
        @user         = user
        @view_context = view_context
      end

      def resume_names_with_date
        view_context.filenames_with_date(resumes)
      end

      def cover_letter_names_with_date
        view_context.filenames_with_date(cover_letters)
      end

      private

      def resumes
        @resumes ||= user.resumes_with_blob
      end

      def cover_letters
        @cover_letters ||= user.cover_letters_with_blob
      end
    end
  end
end
