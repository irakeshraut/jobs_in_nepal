# frozen_string_literal: true

class Job < ApplicationRecord
  STATUS = %w[Active Expired Closed].freeze
  TYPE   = ['Full Time', 'Part Time', 'Casual', 'Contract', 'Freelance'].freeze
  JOB_TYPE = { 'Top Job' => 1, 'Hot Job' => 2, 'Normal Job' => 3 }.freeze

  validates :title,           presence: true
  validates :category,        presence: true, inclusion: { in: Category::LIST.keys }
  validates :location,        presence: true
  validates :employment_type, presence: true, inclusion: { in: Job::TYPE }
  validates :status,          presence: true, inclusion: { in: Job::STATUS }
  validates :job_type,        presence: true, inclusion: { in: Job::JOB_TYPE.values }

  # TODO: add validation presence of company_name, redirect_url when job is created by Admin
  belongs_to :user
  has_many :applicants, dependent: :destroy
  has_many :views,      dependent: :destroy
  has_many :bookmarks,  dependent: :destroy
  has_many :users, through: :applicants

  has_rich_text :description
  validates :description, presence: true

  scope :active,  -> { where(status: 'Active') }
  scope :closed,  -> { where(status: 'Closed') }
  scope :expired, -> { where(status: 'Expired') }
  scope :filter_by_title,      ->(title)    { where('lower(title) like ?', "%#{title.downcase}%") }
  scope :filter_by_category,   ->(category) { where(category:) }
  scope :filter_by_location,   ->(location) { where('lower(location) like ?', "%#{location.downcase}%") }
  scope :filter_by_status,     ->(status)   { where('lower(status) like ?', "%#{status.downcase}%") }
  scope :created_by_employers, -> { joins(:user).where(users: { role: 'employer' }) }
  scope :created_by_admin,     -> { joins(:user).where(users: { role: 'admin' }) }
  scope :old_jobs,             -> { where('created_at < ?', 30.days.ago).where.not(status: 'Expired') }
  scope :with_company_logo,    -> { includes(user: { company: [logo_attachment: :blob] }) }

  scope :hot_jobs,    -> { where(job_type: 1) }
  scope :top_jobs,    -> { where(job_type: 2) }
  scope :normal_jobs, -> { where(job_type: 3) }

  def active?
    status == 'Active'
  end

  def expired?
    status == 'Expired'
  end

  def closed?
    status == 'Closed'
  end

  def created_by_admin?
    user.admin?
  end

  def created_by_employer?
    user.employer?
  end

  # TODO: move this to query object
  def similar_jobs
    Job.includes(user: { company: [logo_attachment: :blob] })
       .where('lower(title) like :title OR lower(category) like :category',
              title: "%#{title.downcase}%", category: category.downcase)
       .where.not(id:).active.order(created_at: :desc).limit(4)
  end
end
