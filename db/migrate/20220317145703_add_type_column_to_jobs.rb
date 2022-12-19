# frozen_string_literal: true

class AddTypeColumnToJobs < ActiveRecord::Migration[6.0]
  def change
    add_column :jobs, :job_type, :integer, null: false
  end
end
