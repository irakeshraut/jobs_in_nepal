# frozen_string_literal: true

module Service
  module Password
    class Update
      include BaseService

      def initialize(user, params)
        @user   = user
        @params = params
      end

      def call
        add_invalid_password_error and return unless valid_current_password?

        add_error_message unless update_password
      end

      private

      attr_reader :user, :params

      # TODO: fix Unpermitted parameters: :authenticity_token, :commit, :id
      def valid_current_password?
        user.valid_password?(params[:current_password])
      end

      def add_invalid_password_error
        errors.add(:base, 'Invalid current password')
      end

      def update_password
        user.update(params.except(:current_password))
      end

      def add_error_message
        user.errors.full_messages.each { |message| errors.add(:base, message) }
      end
    end
  end
end
