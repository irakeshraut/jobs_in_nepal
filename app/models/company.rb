# frozen_string_literal: true

class Company < ApplicationRecord
  validates :name, presence: true
  validates :phone, presence: true

  has_many :users, dependent: :destroy
  has_one_attached :logo

  validates :logo, size: { less_than: 2.megabytes }
  validate :logo_validation

  accepts_nested_attributes_for :users

  has_rich_text :description

  before_save :delete_empty_description

  private

  def logo_validation
    return unless logo.attached? && !logo.image?

    errors.add(:base, 'Logo must be Image type.')
  end

  def delete_empty_description
    description.destroy if description.body.blank?
  end
end
