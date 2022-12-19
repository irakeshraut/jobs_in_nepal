# frozen_string_literal: true

class ChangeDatatypeForEducation < ActiveRecord::Migration[6.0]
  def change
    change_column :educations, :expected_finish_month, 'integer USING CAST(expected_finish_month AS integer)'
  end
end
