# frozen_string_literal: true

class WorkExperience < ApplicationRecord
  validates :job_title, presence: true
  validates :company_name, presence: true
  validates :still_in_role, inclusion: { in: [true, false] }
  validates :start_month, presence: true
  validates :start_year, presence: true
  validates :finish_month, presence: true, unless: :still_in_role
  validates :finish_year, presence: true, unless: :still_in_role

  has_rich_text :description

  belongs_to :user

  before_save :clean_up_work_experience_finish_time
  before_save :delete_empty_description

  def clean_up_work_experience_finish_time
    return unless still_in_role

    self.finish_month = nil
    self.finish_year = nil
  end

  def delete_empty_description
    description.destroy if description.body.blank?
  end
end
