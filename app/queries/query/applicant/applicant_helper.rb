# frozen

module Query
  module Applicant
    module ApplicantHelper
      def find_user
        User.find(params[:id])
      end

      def find_applicant
        job.applicants.find_by(user_id: params[:id])
      end
    end
  end
end
