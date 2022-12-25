# frozen_string_literal: true

module Presenter
  module Applicant
    class Show
      attr_reader :user, :applicant

      def initialize(user, applicant)
        @user      = user
        @applicant = applicant
      end

      def resume?
        resume.present?
      end

      def cover_letter?
        cover_letter.present?
      end

      private

      def resume
        @resume ||= Query::Applicant::Resume::Find.call(@user, applicant)
      end

      def cover_letter
        @cover_letter ||= Query::Applicant::CoverLetter::Find.call(@user, applicant)
      end
    end
  end
end
