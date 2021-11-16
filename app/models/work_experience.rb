class WorkExperience < ApplicationRecord
  validates :job_title, presence: true
  validates :company_name, presence: true

  belongs_to :user
end
