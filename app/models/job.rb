include ActiveSupport::NumberHelper
include ActionView::Helpers::NumberHelper

class Job < ApplicationRecord
  STATUS = ['Active', 'Expired', 'Closed'].freeze
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
  has_many :views, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  has_rich_text :description
  validates :description, presence: true

  scope :active, -> { where(status: 'Active') }
  scope :closed, -> { where(status: 'Closed') }
  scope :expired, -> { where(status: 'Expired') }
  scope :filter_by_title, ->(title) { where("lower(title) like ?", "%#{title.downcase}%") }
  scope :filter_by_category, ->(category) { where(category: category) }
  scope :filter_by_location, ->(location) { where("lower(location) like ?", "%#{location.downcase}%") }
  scope :filter_by_status, ->(status) { where("lower(status) like ?", "%#{status.downcase}%") }
  scope :created_by_employers, -> { joins(:user).where(users: { role: 'employer' }) }

  scope :created_this_week, -> { where(created_at: Time.zone.now.beginning_of_week..Time.zone.now.end_of_week) }
  scope :created_this_month, -> { where(created_at: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month) }

  def active?
    status == 'Active'
  end

  def expired?
    status == 'Expired'
  end

  def closed?
    status == 'Closed'
  end

  def salary
    if min_salary.present? && max_salary.present?
      "Rs #{number_to_human(min_salary, format: '%n%u', precision: 2, units: { thousand: 'K', million: 'M', billion: 'B' })} -
       Rs #{number_to_human(max_salary, format: '%n%u', precision: 2, units: { thousand: 'K', million: 'M', billion: 'B' })}"
    elsif min_salary.present? && max_salary.nil?
      "Rs #{number_to_human(min_salary, format: '%n%u', precision: 2, units: { thousand: 'K', million: 'M', billion: 'B' })}"
    elsif max_salary.present? && min_salary.nil?
      "Rs #{number_to_human(max_salary, format: '%n%u', precision: 2, units: { thousand: 'K', million: 'M', billion: 'B' })}"
    else
      'Salary Not Mentioned'
    end
  end

  def full_salary
    if min_salary.present? && max_salary.present?
      "Rs  #{number_with_delimiter(min_salary)} - Rs #{number_with_delimiter(max_salary)}"
    elsif min_salary.present? && max_salary.nil?
      "Rs #{number_with_delimiter(min_salary)}"
    elsif max_salary.present? && min_salary.nil?
      "Rs #{number_with_delimiter(max_salary)}"
    else
      'Salary Not Mentioned'
    end
  end

  def created_by_admin?
    company_name.present? && redirect_link.present? && user.admin?
  end

  def similar_jobs
    jobs = Job.where("lower(title) like ?", self.title.downcase).or(Job.where("lower(category) like?", self.category.downcase))
      .where.not(id: self.id).active.order(created_at: :desc).limit(4)
    created_by_employer = jobs.joins(:user).where(users: { role: 'employer' })
    if created_by_employer.present?
      jobs = jobs.includes(user: { company: [logo_attachment: :blob] })
    end
    jobs
  end
end
