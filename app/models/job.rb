class Job < ApplicationRecord
  STATUS = ['Active', 'Expired', 'Close'].freeze
  TYPE   = ['Full Time', 'Part Time', 'Casual', 'Contract', 'Freelance'].freeze

  validates :title,           presence: true
  validates :category,        presence: true
  validates :location,        presence: true
  validates :employment_type, presence: true
  validates :employment_type, inclusion: { in: Job::TYPE }
  validates :status,          presence: true
  validates :status,          inclusion: { in: Job::STATUS }
  validates :user,            presence: true

  belongs_to :user

  has_rich_text :description
end
