# frozen_string_literal: true

# You have to provide either (job and params) or (user and applicant) to use this class.
module Query
  module Applicant
    module Resume
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
          return if applicant.resume_name.blank?

          find_resume
        end

        private

        attr_reader :job, :params, :user, :applicant, :resume_date

        def find_resume
          resume_name, @resume_date = applicant.resume_name.split(' - ')
          resumes.where(active_storage_blobs: { filename: resume_name, created_at: }).first
        end

        def resumes
          # TODO: test if resumes.last will work, may be fixed in rails now
          user.resumes.order(created_at: :desc).includes(:blob).references(:blob)
        end

        def created_at
          Date.parse(resume_date).all_day
        end
      end
    end
  end
end
