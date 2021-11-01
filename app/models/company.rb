class Company < ApplicationRecord
  validates :name, presence: true
  validates :phone, presence: true

  has_many :users, dependent: :destroy
  accepts_nested_attributes_for :users
end
