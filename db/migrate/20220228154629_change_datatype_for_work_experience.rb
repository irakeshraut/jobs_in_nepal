# frozen_string_literal: true

class ChangeDatatypeForWorkExperience < ActiveRecord::Migration[6.0]
  def change
    change_column :work_experiences, :start_month, 'integer USING CAST(start_month AS integer)', null: false
    change_column :work_experiences, :finish_month, 'integer USING CAST(finish_month AS integer)', null: true
  end
end
