# frozen_string_literal: true

module Service
  module CoverLetter
    module Old
      class Delete
        include BaseService

        def initialize(user)
          @user = user
        end

        def call
          return unless cover_letter_to_delete_count.positive?

          find_old_cover_letters.destroy_all
        end

        private

        attr_reader :user, :cover_letters

        def cover_letter_to_delete_count
          @cover_letter_to_delete_count ||= user.cover_letters.count - 10
        end

        def find_old_cover_letters
          user.cover_letters.includes(:blob).order(created_at: :asc).limit(cover_letter_to_delete_count)
        end
      end
    end
  end
end
