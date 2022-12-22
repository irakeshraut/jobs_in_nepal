# frozen_string_literal: true

module Query
  module Applicant
    module CoverLetter
      class Find
        include BaseQuery

        def initialize(user, applicant)
          @user      = user
          @applicant = applicant
        end

        def call
          find_cover_letter
        end

        private

        attr_reader :user, :applicant

        def find_cover_letter
          cover_letters.where(active_storage_blobs: { filename: applicant.cover_letter_name }).first
        end

        def cover_letters
          user.cover_letters_with_blob
        end
      end
    end
  end
end
