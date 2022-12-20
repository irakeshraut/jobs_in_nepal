# frozen_string_literal: true

module BaseQuery
  extend ActiveSupport::Concern

  module ClassMethods
    def call(*args, **kwargs)
      new(*args, **kwargs).call
    end
  end

  # implement all the steps required to complete this use case
  def call
    raise NotImplementedError
  end
end
