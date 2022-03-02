class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.implicit_order_column = :created_at

  scope :created_today, -> { where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day) }
end
