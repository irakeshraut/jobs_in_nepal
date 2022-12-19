# frozen_string_literal: true

class AddColumnToApplicants < ActiveRecord::Migration[6.0]
  def change
    add_column :applicants, :viewed_by_employer, :boolean, default: false
  end
end
