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
  has_many :work_experiences, inverse_of: :user, dependent: :destroy
  accepts_nested_attributes_for :work_experiences, reject_if: :all_blank, allow_destroy: true

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
