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
        return if params[:cover_letter_file].blank?

        upload_cover_letter
        set_cover_letter_name
        delete_old_cover_letters
      end

      private

      attr_reader :user, :applicant, :params

      def attach_existing_cover_letter
        applicant.cover_letter_name = params[:cover_letter]
      end

      def upload_cover_letter
        add_error_message unless user.cover_letters.attach(io: params[:cover_letter_file], filename:)
      end

      def filename
        @filename ||= "#{original_filename} - #{Time.zone.now.to_i}"
      end

      def original_filename
        params[:cover_letter_file].original_filename
      end

      def set_cover_letter_name
        applicant.cover_letter_name = filename
      end

      def delete_old_cover_letters
        Service::CoverLetter::Old::Delete.call(user)
      end

      def add_error_message
        user.errors.full_messages.each { |error| errors.add(:base, error) }
      end
    end
  end
end
