# frozen_string_literal: true

class User < ApplicationRecord
  authenticates_with_sorcery!

  before_update :setup_activation, if: -> { email_changed? }
  after_update :send_activation_needed_email!, if: -> { previous_changes['email'].present? }

  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :password, length: { minimum: 8 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :email, presence: true
  validates :email, uniqueness: true
  validates :email, email: { mode: :strict, require_fqdn: true }
  validates :role, presence: true, inclusion: { in: %w[employer job_seeker admin] }

  belongs_to :company, optional: true
  has_many :jobs, dependent: :destroy
  has_many :work_experiences, lambda {
                                order('start_year DESC, start_month DESC, finish_year DESC, finish_month DESC')
                              }, inverse_of: :user, dependent: :destroy
  has_many :educations, -> { order(finished_year: :desc) }, inverse_of: :user, dependent: :destroy
  has_many :applicants, dependent: :destroy
  has_many :applied_jobs, through: :applicants, source: :job
  has_many :bookmarks, dependent: :destroy

  accepts_nested_attributes_for :work_experiences, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :educations, reject_if: :all_blank, allow_destroy: true

  has_many_attached :resumes, dependent: :destroy
  has_many_attached :cover_letters, dependent: :destroy
  has_one_attached :avatar, dependent: :destroy

  validates :resumes, content_type: Document::VALID_TYPES
  validates :resumes, size: { less_than: 2.megabytes }
  validates :cover_letters, content_type: Document::VALID_TYPES
  validates :cover_letters, size: { less_than: 2.megabytes }
  validates :avatar, size: { less_than: 2.megabytes }
  validates :profile_visible, inclusion: { in: [true, false] }
  validates :visible_resume_name, presence: true, if: :profile_visible
  validates :phone_no, presence: true, if: :profile_visible
  validates :skills, presence: true, if: :profile_visible
  validates :city, presence: true, if: :profile_visible

  scope :filter_by_name, ->(name) { where("lower(first_name) || ' ' || lower(last_name) like ?", "%#{name.downcase}%") }
  scope :filter_by_status, ->(status) { where(applicants: { status: }) }
  scope :with_education,       -> { includes(educations: :rich_text_course_highlights) }
  scope :with_work_experience, -> { includes(work_experiences: :rich_text_description) }
  scope :with_education_and_work_experience, -> { with_education.with_work_experience }

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

  # TODO: try to delete this before save callbacks are not good, this will update everytime when user are updated.
  def clean_up_visible_resume_name
    self.visible_resume_name = nil unless profile_visible
  end

  # TODO: may need to move these to concerns
  def resumes_with_blob
    resumes.includes(:blob).order(created_at: :desc)
  end

  def cover_letters_with_blob
    cover_letters.includes(:blob).order(created_at: :desc)
  end
end
