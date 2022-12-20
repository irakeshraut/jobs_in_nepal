# frozen_string_literal: true

class Applicant < ApplicationRecord
  STATUS = %w[Shortlisted Rejected].freeze

  validates :resume_name, presence: true
  validates :status, inclusion: { in: STATUS }, allow_nil: true

  belongs_to :job
  belongs_to :user

  def shortlisted?
    status == 'Shortlisted'
  end

  def rejected?
    status == 'Rejected'
  end
end
