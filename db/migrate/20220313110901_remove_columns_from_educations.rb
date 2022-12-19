# frozen_string_literal: true

class RemoveColumnsFromEducations < ActiveRecord::Migration[6.0]
  def change
    remove_column :educations, :course_highlights
  end
end
