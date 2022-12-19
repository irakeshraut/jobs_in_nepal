# frozen_string_literal: true

class RenameEducationColumnName < ActiveRecord::Migration[6.0]
  def change
    rename_column :educations, :expected_finished_month, :expected_finish_month
    rename_column :educations, :expected_finished_year, :expected_finish_year
  end
end
