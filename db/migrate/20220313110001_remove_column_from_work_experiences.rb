# frozen_string_literal: true

class RemoveColumnFromWorkExperiences < ActiveRecord::Migration[6.0]
  def change
    remove_column :work_experiences, :description
  end
end
