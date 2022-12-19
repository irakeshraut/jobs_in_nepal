# frozen_string_literal: true

class AddColumnToJobs < ActiveRecord::Migration[6.0]
  def change
    add_column :jobs, :closed_by_admin, :boolean
  end
end
