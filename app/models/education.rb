class Education < ApplicationRecord
  validates :institution_name, presence: true
  validates :course_name,      presence: true
  validates :course_completed, inclusion: { in:  [true, false] }

  belongs_to :user

  before_save :clean_up_course_finished_time

  def clean_up_course_finished_time
    if course_completed
      self.expected_finished_month = nil
      self.expected_finished_year = nil
    else
      self.finished_year = nil
    end
  end
end
