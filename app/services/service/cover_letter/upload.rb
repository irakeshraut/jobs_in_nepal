# frozen_string_literal: true

module Service
  module CoverLetter
    class Upload
      include BaseService

      def initialize(user, applicant, params)
        @user      = user
        @applicant = applicant
        @params    = params
      end

      def call
        attach_existing_cover_letter and return if params[:cover_letter].present?

        upload_new_cover_letter if params[:cover_letter_file].present?
      end

      private

      attr_reader :user, :applicant, :params

      def attach_existing_cover_letter
        applicant.cover_letter_name = params[:cover_letter]
      end

      def upload_new_cover_letter
        if user.cover_letters.attach(params[:cover_letter_file])
          set_cover_letter_name
          user.delete_cover_letters_greater_than_10
        else
          add_error_messages
        end
      end

      def set_cover_letter_name
        cover_letter = user.cover_letters.order(created_at: :desc).first
        applicant.cover_letter_name = "#{cover_letter.filename} - #{cover_letter.created_at.strftime('%d/%m/%Y')}"
      end

      def add_error_messages
        user.errors.full_messages.each { |error| errors.add(:base, error) }
      end
    end
  end
end
