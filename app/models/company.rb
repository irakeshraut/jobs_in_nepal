class Company < ApplicationRecord
  validates :name, presence: true
  validates :phone, presence: true
end
