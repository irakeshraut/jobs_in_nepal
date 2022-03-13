class Education < ApplicationRecord
  validates :institution_name, presence: true
  validates :course_name,      presence: true
  validates :course_completed, inclusion: { in:  [true, false] }
  validates :finished_year, presence: true,  if: :course_completed
  validates :expected_finish_month, presence: true,  unless: :course_completed
  validates :expected_finish_year, presence: true, unless: :course_completed

  has_rich_text :course_highlights

  belongs_to :user

  before_save :clean_up_course_finish_time

  def clean_up_course_finish_time
    if course_completed
      self.expected_finish_month = nil
      self.expected_finish_year = nil
    else
      self.finished_year = nil
    end
  end
end
