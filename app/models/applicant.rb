class Applicant < ApplicationRecord
  validates :resume_name, presence: true
  belongs_to :job
  belongs_to :user
end
