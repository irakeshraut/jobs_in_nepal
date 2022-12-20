# frozen_literal_string: true

module ApplicantQuery
  class FindResume
    include BaseQuery

    def initialize(applicant_user, applicant)
      @applicant_user = applicant_user
      @applicant      = applicant
    end

    def call
      return if applicant.resume_name.blank?

      find_resume_for_applied_job
    end

    private

    attr_reader :applicant_user, :applicant, :resume_date

    def find_resume_for_applied_job
      resume_name, @resume_date = applicant.resume_name.split(' - ')
      resumes.where(active_storage_blobs: { filename: resume_name, created_at: }).first
    end

    def resumes
      # TODO: test if resumes.last will work, may be fixed in rails now
      applicant_user.resumes.order(created_at: :desc).includes(:blob).references(:blob)
    end

    def created_at
      Date.parse(resume_date).beginning_of_day..Date.parse(resume_date).end_of_day
    end
  end
end
