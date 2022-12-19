# frozen_string_literal: true

class UpdateColumnToWorkExperience < ActiveRecord::Migration[6.0]
  def change
    change_column :work_experiences, :still_in_role, :boolean, null: false, default: true
  end
end
