module Query
  module Applicant
    module ApplicantHelper
      def find_user
        User.find(params[:id])
      end

      def find_applicant
        job.applicants.find_by(job_id: params[:job_id], user_id: params[:id])
      end
    end
  end
end