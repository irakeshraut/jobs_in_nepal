class WorkExperience < ApplicationRecord
  validates :job_title, presence: true
  validates :company_name, presence: true
  validates :start_month, presence: true
  validates :start_year, presence: true
  validates :finish_month, presence: true, unless: :still_in_role
  validates :finish_year, presence: true, unless: :still_in_role

  belongs_to :user
end
