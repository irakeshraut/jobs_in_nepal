# frozen_string_literal: true

module BaseService
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  module ClassMethods
    # The perform method of a UseCase should always return itself
    def call(*args)
      new(*args).tap(&:call)
    end
  end

  # implement all the steps required to complete this use case
  def call
    raise NotImplementedError
  end

  # inside of call, add errors if the use case did not succeed
  def success?
    errors.none?
  end
end
