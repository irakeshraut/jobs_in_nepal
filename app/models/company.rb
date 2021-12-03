class Company < ApplicationRecord
  validates :name, presence: true
  validates :phone, presence: true

  has_many :users, dependent: :destroy
  has_one_attached :logo

  validates :logo, size: { less_than: 2.megabytes }
  validate :logo_validation

  accepts_nested_attributes_for :users

  private

  def logo_validation
    if logo.attached? && !logo.image?
      errors[:base] << 'Logo must be Image type.'
    end
  end
end
