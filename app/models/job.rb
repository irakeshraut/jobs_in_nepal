include ActiveSupport::NumberHelper

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
  has_many :applicants, dependent: :destroy
  has_many :users, through: :applicants

  has_rich_text :description
  validates :description, presence: true

  scope :active, -> { where(status: 'Active') }
  scope :filter_by_title, ->(title) { where("lower(title) like ?", "%#{title.downcase}%") }
  scope :filter_by_category, ->(category) { where(category: category) }
  scope :filter_by_location, ->(location) { where("lower(location) like ?", "%#{location.downcase}%") }

  def salary
    if min_salary.present? && max_salary.present?
      "Rs #{number_to_human(min_salary, format: '%n%u', precision: 2, units: { thousand: 'K', million: 'M', billion: 'B' })} -
       Rs #{number_to_human(max_salary, format: '%n%u', precision: 2, units: { thousand: 'K', million: 'M', billion: 'B' })}"
    elsif min_salary.present? && max_salary.nil?
      "Rs #{number_to_human(min_salary, format: '%n%u', precision: 2, units: { thousand: 'K', million: 'M', billion: 'B' })}"
    elsif max_salary.present? && min_salary.nil?
      "Rs #{number_to_human(max, format: '%n%u', precision: 2, units: { thousand: 'K', million: 'M', billion: 'B' })}"
    else
      'Salary Not Mentioned'
    end
  end

  def created_by_admin?
    company_name.present? && redirect_link.present? && user.role == 'admin'
  end
end
