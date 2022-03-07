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
  validates :profile_visible, inclusion: { in:  [true, false] }
  validates :visible_resume_name, presence: true, if: :profile_visible
  validates :phone_no, presence: true, if: :profile_visible
  validates :skills, presence: true, if: :profile_visible
  validates :city, presence: true, if: :profile_visible

  scope :filter_by_name, ->(name) { where("lower(first_name) || ' ' || lower(last_name) like ?", "%#{name.downcase}%") }
  scope :filter_by_status, ->(status) { where(applicants: { status: status }) }

  before_save :clean_up_visible_resume_name

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

  def delete_resumes_greater_than_10
    resume_count = self.resumes.count
    resume_to_delete_count = resume_count - 10
    if resume_to_delete_count > 0
      if self.profile_visible
        visible_resume_name, resume_created_date = self.visible_resume_name.split(' - ')
        visible_resume = self.resumes.includes(:blob).references(:blob).order(created_at: :desc)
          .where(active_storage_blobs: { filename: visible_resume_name, created_at: Date.parse(resume_created_date).beginning_of_day..Date.parse(resume_created_date).end_of_day }).first
        oldest_resume = self.resumes.includes(:blob).references(:blob).order(created_at: :desc).last
        if visible_resume == oldest_resume
          self.resumes.where.not(id: visible_resume.id).order(created_at: :asc).limit(resume_to_delete_count).destroy_all
        else
          self.resumes.order(created_at: :asc).limit(resume_to_delete_count).destroy_all
        end
      else
        self.resumes.order(created_at: :asc).limit(resume_to_delete_count).destroy_all
      end
    end
  end

  # @user.resumes.last.destroy is not relialbe that why I am looping througn resumes
  def delete_resumes_with_id_nil
    self.resumes.each do |resume|
      resume.destroy if resume.id.nil?
    end
  end

  def split_resumes_in_group_of_2
    if self.resumes.size > 0 
       self.resumes.order(created_at: :desc).in_groups_of((self.resumes.size/2.0).round, false)
    else
      [[],[]]
    end
  end

  def delete_cover_letters_greater_than_10
    cover_letter_count = self.cover_letters.count
    cover_letter_to_delete_count = cover_letter_count - 10
    if cover_letter_to_delete_count > 0
      self.cover_letters.order(created_at: :asc).limit(cover_letter_to_delete_count).destroy_all
    end
  end

  # @user.cover_letters.last.destroy is not relialbe that why I am looping througn cover_letters
  def delete_cover_letters_with_id_nil
    self.cover_letters.each do |cover_letter|
      cover_letter.destroy if cover_letter.id.nil?
    end
  end

  def split_cover_letters_in_group_of_2
    if self.cover_letters.size > 0 
       self.cover_letters.order(created_at: :desc).in_groups_of((self.cover_letters.size/2.0).round, false)
    else
      [[],[]]
    end
  end

  def clean_up_visible_resume_name
    unless profile_visible
      self.visible_resume_name = nil
    end
  end
end
