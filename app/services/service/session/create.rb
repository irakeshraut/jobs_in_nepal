# frozen_string_literal: true

module Service
  module Session
    class Create
      include BaseService

      def initialize(user, params)
        @user   = user
        @params = params
      end

      def call
        return if user
        add_activation_pending_error and return if find_user && activation_pending?

        add_error_message
      end

      private

      attr_reader :user, :params

      def add_activation_pending_error
        message = 'You need to activate your account. Please check your email for activation link.'
        errors.add(:base, message)
      end

      def find_user
        @user = User.find_by(email: params[:email])
      end

      def activation_pending?
        @user.activation_state == 'pending'
      end

      def add_error_message
        errors.add(:base, 'Login Failed: Invalid Email or Password')
      end
    end
  end
end
