# frozen_string_literal: true

class View < ApplicationRecord
  validates :ip, presence: true
  belongs_to :job
end
