# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.implicit_order_column = :created_at # This is not working for active storage eg user.resumes.last is incorrect

  scope :created_today,      -> { where(created_at: Time.zone.now.all_day) }
  scope :created_this_week,  -> { where(created_at: Time.zone.now.all_week) }
  scope :created_this_month, -> { where(created_at: Time.zone.now.all_month) }
end
