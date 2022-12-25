# frozen_string_literal: true

class Company < ApplicationRecord
  validates :name,  presence: true
  validates :phone, presence: true
  validates :logo, size: { less_than: 2.megabytes }, content_type: %r{\Aimage/.*\z}

  has_many :users, dependent: :destroy
  has_one_attached :logo

  has_rich_text :description

  accepts_nested_attributes_for :users

  before_save :delete_empty_description

  private

  def delete_empty_description
    description.destroy if description.body.blank?
  end
end
