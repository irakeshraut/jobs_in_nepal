# frozen_string_literal: true

module Query
  module Applicant
    module Resume
      class Find
        include BaseQuery

        def initialize(user, applicant)
          @user      = user
          @applicant = applicant
        end

        def call
          find_resume
        end

        private

        attr_reader :user, :applicant

        def find_resume
          resumes.where(active_storage_blobs: { filename: applicant.resume_name }).first
        end

        def resumes
          user.resumes_with_blob
        end
      end
    end
  end
end
