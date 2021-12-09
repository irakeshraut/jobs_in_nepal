class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :password, length: { minimum: 8 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :email,  presence: true
  validates :email, uniqueness: true
  validates :email, email: { mode: :strict, require_fqdn: true }
  validates :role, presence: true, inclusion: { in: %w(employer job_seeker admin) }

  belongs_to :company, optional: true
  has_many :jobs, dependent: :destroy
  has_many :work_experiences, inverse_of: :user, dependent: :destroy
  has_many :educations, inverse_of: :user, dependent: :destroy
  has_many :applicants, dependent: :destroy
  has_many :applied_jobs, through: :applicants, source: :job

  accepts_nested_attributes_for :work_experiences, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :educations, reject_if: :all_blank, allow_destroy: true

  has_many_attached :resumes, dependent: :destroy 
  has_many_attached :cover_letters, dependent: :destroy
  has_one_attached :avatar, dependent: :destroy

  validates :resumes, content_type:  ['application/pdf', 'application/x-ole-storage', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/msword', 'text/plain', 'application/rtf']
  validates :resumes, size: { less_than: 2.megabytes }
  validates :cover_letters, content_type:  ['application/pdf', 'application/x-ole-storage', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/msword', 'text/plain', 'application/rtf']
  validates :cover_letters, size: { less_than: 2.megabytes }
  validates :avatar, size: { less_than: 2.megabytes }

  scope :filter_by_name, ->(name) { where("lower(first_name) || ' ' || lower(last_name) like ?", "%#{name.downcase}%") }
  scope :filter_by_status, ->(status) { where(applicants: { status: status }) }


  def admin?
    role == 'admin'
  end

  def employer?
    role == 'employer'
  end

  def job_seeker?
    role == 'job_seeker'
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
