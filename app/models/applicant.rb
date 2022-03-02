class Applicant < ApplicationRecord
  STATUS = ['Shortlisted', 'Rejected'].freeze

  validates :resume_name, presence: true
  belongs_to :job
  belongs_to :user

  def shortlisted?
    status == 'Shortlisted'
  end

  def rejected?
    status == 'Rejected'
  end
end
