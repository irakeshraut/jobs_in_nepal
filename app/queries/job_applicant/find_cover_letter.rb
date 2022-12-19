# frozen_literal_string: true

module JobApplicant
  class FindCoverLetter
    include BaseQuery

    def initialize(applicant_user, applicant)
      @applicant_user = applicant_user
      @applicant      = applicant
    end

    def call
      return if applicant.cover_letter_name.blank?

      find_cover_letter_for_applied_job
    end

    private

    attr_reader :applicant_user, :applicant, :cover_letter_date

    def find_cover_letter_for_applied_job
      cover_letter_name, @cover_letter_date = applicant.cover_letter_name.split(' - ')
      cover_letters.where(active_storage_blobs: { filename: cover_letter_name, created_at: }).first
    end

    def cover_letters
      # TODO: test if cover_letters.last will work, may be fixed in rails now
      applicant_user.cover_letters.order(created_at: :desc).includes(:blob).references(:blob)
    end

    def created_at
      Date.parse(cover_letter_date).beginning_of_day..Date.parse(cover_letter_date).end_of_day
    end
  end
end
