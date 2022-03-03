class User < ApplicationRecord
  authenticates_with_sorcery!

  before_update :setup_activation, if: -> { email_changed? }
  after_update :send_activation_needed_email!, if: -> { previous_changes["email"].present? }

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
  has_many :work_experiences, -> { order("start_year DESC, start_month DESC, finish_year DESC, finish_month DESC") }, inverse_of: :user, dependent: :destroy
  has_many :educations, -> { order(finished_year: :desc) }, inverse_of: :user, dependent: :destroy
  has_many :applicants, dependent: :destroy
  has_many :applied_jobs, through: :applicants, source: :job
  has_many :bookmarks, dependent: :destroy

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

  def delete_resume_greater_than_10
    resume_count = self.resumes.count
    resume_to_delete_count = resume_count - 10
    if resume_to_delete_count > 0
      self.resumes.order(created_at: :asc).limit(resume_to_delete_count).destroy_all
    end
  end

  # @user.resume.last.destroy is not relialbe that why I am looping througn resumes
  def delete_resume_with_id_nil
    self.resumes.each do |resume|
      resume.destroy if resume.id.nil?
    end
  end

  def split_resume_in_group_of_2
    if self.resumes.size > 0 
       self.resumes.order(created_at: :desc).in_groups_of((self.resumes.size/2.0).round, false)
    else
      [[],[]]
    end
  end
end
