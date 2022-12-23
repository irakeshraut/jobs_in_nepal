# frozen_string_literal: true

module Service
  module Resume
    module Old
      class Delete
        include BaseService

        def initialize(user)
          @user = user
        end

        def call
          return unless resume_to_delete_count.positive?

          find_old_resumes.destroy_all
        end

        private

        attr_reader :user, :resumes

        def resume_to_delete_count
          @resume_to_delete_count ||= user.resumes.count - 10
        end

        def find_old_resumes
          user.resumes.includes(:blob).order(created_at: :asc)
              .where.not(active_storage_blobs: { filename: user.visible_resume_name })
              .limit(resume_to_delete_count)
        end
      end
    end
  end
end
