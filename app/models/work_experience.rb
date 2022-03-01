class WorkExperience < ApplicationRecord
  validates :job_title, presence: true
  validates :company_name, presence: true
  validates :still_in_role, inclusion: { in:  [true, false] }
  validates :start_month, presence: true
  validates :start_year, presence: true
  validates :finish_month, presence: true, unless: :still_in_role
  validates :finish_year, presence: true, unless: :still_in_role

  belongs_to :user

  before_save :clean_up_work_experience_finish_time

  def clean_up_work_experience_finish_time
    if still_in_role
      self.finish_month = nil
      self.finish_year = nil
    end
  end
end
