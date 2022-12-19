# frozen_string_literal: true

module Query
  extend ActiveSupport::Concern

  module ClassMethods
    def call(*args)
      new(*args).call
    end
  end

  # implement all the steps required to complete this use case
  def call
    raise NotImplementedError
  end
end
