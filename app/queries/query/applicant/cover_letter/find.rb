# frozen_string_literal: true

# You have to provide either (job and params) or (user and applicant) to use this class.
module Query
  module Applicant
    module CoverLetter
      class Find
        include BaseQuery
        include ApplicantHelper

        def initialize(job: nil, params: nil, user: nil, applicant: nil)
          @job       = job
          @params    = params
          @user      = user      || find_user
          @applicant = applicant || find_applicant
        end

        def call
          return if applicant.cover_letter_name.blank?

          find_cover_letter
        end

        private

        attr_reader :job, :params, :user, :applicant, :cover_letter_date

        def find_cover_letter
          cover_letter_name, @cover_letter_date = applicant.cover_letter_name.split(' - ')
          cover_letters.where(active_storage_blobs: { filename: cover_letter_name, created_at: }).first
        end

        def cover_letters
          user.cover_letters.order(created_at: :desc).includes(:blob).references(:blob)
        end

        def created_at
          Date.parse(cover_letter_date).all_day
        end
      end
    end
  end
end
